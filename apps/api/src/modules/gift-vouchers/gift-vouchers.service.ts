import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomBytes } from 'node:crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { GiftVoucherEntity } from '../../database/entities/gift-voucher.entity';
import { GiftVoucherEventEntity } from '../../database/entities/gift-voucher-event.entity';
import { EntitlementsService } from '../entitlements/entitlements.service';
import {
  GIFT_VOUCHER_ALREADY_REDEEMED,
  GIFT_VOUCHER_CODE_REQUIRED,
  GIFT_VOUCHER_CREDIT_AMOUNT_INVALID,
  GIFT_VOUCHER_EXPIRED,
  GIFT_VOUCHER_INVALID,
  GIFT_VOUCHER_NOT_ACTIVE,
  GIFT_VOUCHER_NOT_FOUND,
  GIFT_VOUCHER_VOIDED,
  type AdminGenerateGiftVoucherResponseDto,
  type GeneratedGiftVoucherDto,
  type GiftVoucherAdminDto,
  type RedeemGiftVoucherResponseDto,
} from './gift-vouchers.types';

const VOUCHER_CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const VOUCHER_CODE_SEGMENT_LENGTH = 4;
const VOUCHER_CODE_SEGMENTS = 3;
const VOUCHER_CODE_MAX_RETRIES = 8;

interface RedeemVoucherTransactionResult {
  redeemedVoucher: GiftVoucherEntity | null;
  creditsAdded: number;
  rejection: BadRequestException | ConflictException | null;
}

@Injectable()
export class GiftVouchersService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(GiftVoucherEntity)
    private readonly voucherRepo: Repository<GiftVoucherEntity>,
    private readonly entitlementsService: EntitlementsService,
  ) {}

  async listAdminVouchers(): Promise<GiftVoucherAdminDto[]> {
    const vouchers = await this.voucherRepo.find({
      order: { createdAt: 'DESC' },
      take: 100,
    });
    return vouchers.map((voucher) => this.toAdminDto(voucher));
  }

  async generateAdminVouchers(input: {
    actorUserId: string;
    creditAmount: number;
    count?: number;
    expiresAt?: string;
  }): Promise<AdminGenerateGiftVoucherResponseDto> {
    const creditAmount = this.roundCredits(input.creditAmount);
    if (!Number.isFinite(creditAmount) || creditAmount <= 0) {
      throw new BadRequestException({
        code: GIFT_VOUCHER_CREDIT_AMOUNT_INVALID,
        message: 'Voucher credit amount must be greater than zero.',
      });
    }

    const count = Math.max(1, Math.min(input.count ?? 1, 100));
    const expiresAt = input.expiresAt ? new Date(input.expiresAt) : null;
    const vouchers: GeneratedGiftVoucherDto[] = [];

    await this.dataSource.transaction(async (manager) => {
      for (let index = 0; index < count; index += 1) {
        const generated = await this.createUniqueVoucher({
          manager,
          actorUserId: input.actorUserId,
          creditAmount,
          expiresAt,
        });
        vouchers.push(generated);
      }
    });

    return {
      state: 'success',
      vouchers,
    };
  }

  async redeemVoucher(input: {
    userId: string;
    code: string;
  }): Promise<RedeemGiftVoucherResponseDto> {
    const normalizedCode = this.normalizeCode(input.code);
    const codeHash = this.hashCode(normalizedCode);

    const result =
      await this.dataSource.transaction<RedeemVoucherTransactionResult>(
        async (manager) => {
          const voucher = await manager
            .getRepository(GiftVoucherEntity)
            .createQueryBuilder('voucher')
            .setLock('pessimistic_write')
            .where('voucher.code_hash = :codeHash', { codeHash })
            .getOne();

          if (!voucher) {
            throw new NotFoundException({
              code: GIFT_VOUCHER_INVALID,
              message: 'Gift voucher is invalid or already redeemed.',
            });
          }

          await this.recordEvent(manager, {
            voucher,
            actorUserId: input.userId,
            eventType: 'redeem_attempted',
            outcome: 'success',
            metadata: {
              status: voucher.status,
            },
          });

          if (voucher.expiresAt && voucher.expiresAt < new Date()) {
            if (voucher.status === 'active') {
              voucher.status = 'expired';
              await manager.getRepository(GiftVoucherEntity).save(voucher);
              await this.recordEvent(manager, {
                voucher,
                actorUserId: null,
                eventType: 'expired',
                outcome: 'success',
                metadata: {
                  expiresAt: voucher.expiresAt.toISOString(),
                },
              });
            }
          }

          const rejection = this.getRedeemRejection(voucher);
          if (rejection) {
            await this.recordEvent(manager, {
              voucher,
              actorUserId: input.userId,
              eventType: 'redeem_blocked',
              outcome: 'blocked',
              metadata: {
                status: voucher.status,
                reason:
                  rejection instanceof ConflictException
                    ? GIFT_VOUCHER_ALREADY_REDEEMED
                    : this.readExceptionCode(rejection),
              },
            });
            return {
              redeemedVoucher: null,
              creditsAdded: 0,
              rejection,
            };
          }

          const creditsAdded = this.roundCredits(
            parseFloat(voucher.creditAmount),
          );
          await this.entitlementsService.addCreditsInTransaction(
            manager,
            input.userId,
            creditsAdded,
            'gift_voucher_redeem',
          );

          voucher.status = 'redeemed';
          voucher.redeemedByUserId = input.userId;
          voucher.redeemedAt = new Date();
          const redeemedVoucher = await manager
            .getRepository(GiftVoucherEntity)
            .save(voucher);

          await this.recordEvent(manager, {
            voucher: redeemedVoucher,
            actorUserId: input.userId,
            eventType: 'redeemed',
            outcome: 'success',
            metadata: {
              creditsAdded,
            },
          });

          return {
            redeemedVoucher,
            creditsAdded,
            rejection: null,
          };
        },
      );

    if (result.rejection) {
      throw result.rejection;
    }

    const redeemedVoucher = result.redeemedVoucher;
    if (!redeemedVoucher) {
      throw new NotFoundException({
        code: GIFT_VOUCHER_NOT_FOUND,
        message: 'Gift voucher not found.',
      });
    }

    return {
      state: 'success',
      voucherId: redeemedVoucher.id,
      codeMask: redeemedVoucher.codeMask,
      creditsAdded: result.creditsAdded,
      entitlementSummary: await this.entitlementsService.getEntitlementSummary(
        input.userId,
      ),
    };
  }

  async voidVoucher(input: {
    actorUserId: string;
    voucherId: string;
    reason: string;
  }): Promise<{ state: 'success' | 'reverted'; voucher: GiftVoucherAdminDto }> {
    return this.dataSource.transaction(async (manager) => {
      const voucher = await manager
        .getRepository(GiftVoucherEntity)
        .createQueryBuilder('voucher')
        .setLock('pessimistic_write')
        .where('voucher.id = :voucherId', { voucherId: input.voucherId })
        .getOne();

      if (!voucher) {
        throw new NotFoundException({
          code: GIFT_VOUCHER_NOT_FOUND,
          message: 'Gift voucher not found.',
        });
      }

      if (voucher.status === 'voided') {
        return {
          state: 'reverted',
          voucher: this.toAdminDto(voucher),
        };
      }

      if (voucher.status === 'redeemed') {
        throw new ConflictException({
          code: GIFT_VOUCHER_ALREADY_REDEEMED,
          message: 'Redeemed gift vouchers cannot be voided.',
        });
      }

      voucher.status = 'voided';
      voucher.voidedByUserId = input.actorUserId;
      voucher.voidedAt = new Date();
      voucher.voidReason = input.reason.trim();
      const saved = await manager
        .getRepository(GiftVoucherEntity)
        .save(voucher);
      await this.recordEvent(manager, {
        voucher: saved,
        actorUserId: input.actorUserId,
        eventType: 'voided',
        outcome: 'success',
        metadata: {
          reason: input.reason.trim(),
        },
      });

      return {
        state: 'success',
        voucher: this.toAdminDto(saved),
      };
    });
  }

  private async createUniqueVoucher(input: {
    manager: EntityManager;
    actorUserId: string;
    creditAmount: number;
    expiresAt: Date | null;
  }): Promise<GeneratedGiftVoucherDto> {
    for (let attempt = 1; attempt <= VOUCHER_CODE_MAX_RETRIES; attempt += 1) {
      const code = this.generateCode();
      const normalizedCode = this.normalizeCode(code);
      const voucher = input.manager.getRepository(GiftVoucherEntity).create({
        codeHash: this.hashCode(normalizedCode),
        codeMask: this.maskCode(normalizedCode),
        creditAmount: input.creditAmount.toFixed(2),
        status: 'active',
        expiresAt: input.expiresAt,
        createdByUserId: input.actorUserId,
        redeemedByUserId: null,
        redeemedAt: null,
        voidedByUserId: null,
        voidedAt: null,
        voidReason: null,
        metadata: null,
      });

      try {
        const saved = await input.manager
          .getRepository(GiftVoucherEntity)
          .save(voucher);
        await this.recordEvent(input.manager, {
          voucher: saved,
          actorUserId: input.actorUserId,
          eventType: 'generated',
          outcome: 'success',
          metadata: {
            creditAmount: input.creditAmount,
            expiresAt: input.expiresAt?.toISOString() ?? null,
          },
        });
        return {
          ...this.toAdminDto(saved),
          code,
        };
      } catch (error) {
        if (attempt === VOUCHER_CODE_MAX_RETRIES) {
          throw error;
        }
      }
    }

    throw new BadRequestException({
      code: GIFT_VOUCHER_INVALID,
      message: 'Unable to generate a unique gift voucher code.',
    });
  }

  private getRedeemRejection(
    voucher: GiftVoucherEntity,
  ): BadRequestException | ConflictException | null {
    if (voucher.status === 'redeemed') {
      return new ConflictException({
        code: GIFT_VOUCHER_ALREADY_REDEEMED,
        message: 'Gift voucher has already been redeemed.',
      });
    }

    if (voucher.status === 'voided') {
      return new BadRequestException({
        code: GIFT_VOUCHER_VOIDED,
        message: 'Gift voucher has been voided.',
      });
    }

    if (voucher.status === 'expired') {
      return new BadRequestException({
        code: GIFT_VOUCHER_EXPIRED,
        message: 'Gift voucher has expired.',
      });
    }

    if (voucher.status !== 'active') {
      return new BadRequestException({
        code: GIFT_VOUCHER_NOT_ACTIVE,
        message: 'Gift voucher is not active.',
      });
    }

    return null;
  }

  private async recordEvent(
    manager: EntityManager,
    input: {
      voucher: GiftVoucherEntity;
      actorUserId: string | null;
      eventType: string;
      outcome: 'success' | 'blocked' | 'failure';
      metadata?: Record<string, unknown>;
    },
  ): Promise<void> {
    await manager.getRepository(GiftVoucherEventEntity).save(
      manager.getRepository(GiftVoucherEventEntity).create({
        giftVoucherId: input.voucher.id,
        actorUserId: input.actorUserId,
        eventType: input.eventType,
        outcome: input.outcome,
        metadata: input.metadata ?? null,
      }),
    );
  }

  private generateCode(): string {
    const bytes = randomBytes(
      VOUCHER_CODE_SEGMENTS * VOUCHER_CODE_SEGMENT_LENGTH,
    );
    let cursor = 0;
    const segments: string[] = [];

    for (
      let segmentIndex = 0;
      segmentIndex < VOUCHER_CODE_SEGMENTS;
      segmentIndex += 1
    ) {
      let segment = '';
      for (
        let charIndex = 0;
        charIndex < VOUCHER_CODE_SEGMENT_LENGTH;
        charIndex += 1
      ) {
        segment +=
          VOUCHER_CODE_ALPHABET[bytes[cursor] % VOUCHER_CODE_ALPHABET.length];
        cursor += 1;
      }
      segments.push(segment);
    }

    return `DOC-${segments.join('-')}`;
  }

  private normalizeCode(code: string): string {
    const normalized = code.trim().toUpperCase();
    if (!normalized) {
      throw new BadRequestException({
        code: GIFT_VOUCHER_CODE_REQUIRED,
        message: 'Gift voucher code is required.',
      });
    }
    return normalized;
  }

  private hashCode(normalizedCode: string): string {
    return createHash('sha256')
      .update(`doclyzer:gift-voucher:${normalizedCode}`)
      .digest('hex');
  }

  private maskCode(normalizedCode: string): string {
    if (normalizedCode.length <= 8) {
      return normalizedCode;
    }
    return `${normalizedCode.slice(0, 4)}...${normalizedCode.slice(-4)}`;
  }

  private roundCredits(amount: number): number {
    return Math.round(amount * 100) / 100;
  }

  private readExceptionCode(exception: BadRequestException): string {
    const response = exception.getResponse();
    if (
      typeof response === 'object' &&
      response !== null &&
      'code' in response
    ) {
      const code = (response as { code?: unknown }).code;
      if (typeof code === 'string') return code;
    }
    return GIFT_VOUCHER_NOT_ACTIVE;
  }

  private toAdminDto(voucher: GiftVoucherEntity): GiftVoucherAdminDto {
    return {
      id: voucher.id,
      codeMask: voucher.codeMask,
      creditAmount: parseFloat(voucher.creditAmount),
      status: voucher.status,
      expiresAt: voucher.expiresAt?.toISOString() ?? null,
      redeemedByUserId: voucher.redeemedByUserId,
      redeemedAt: voucher.redeemedAt?.toISOString() ?? null,
      voidedByUserId: voucher.voidedByUserId,
      voidedAt: voucher.voidedAt?.toISOString() ?? null,
      voidReason: voucher.voidReason,
      createdAt: voucher.createdAt.toISOString(),
      updatedAt: voucher.updatedAt.toISOString(),
    };
  }
}
