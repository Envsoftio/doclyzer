import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { SuperadminGuard } from '../auth/superadmin.guard';
import {
  AdminGenerateGiftVoucherDto,
  AdminVoidGiftVoucherDto,
  RedeemGiftVoucherDto,
} from './gift-vouchers.types';
import { GiftVouchersService } from './gift-vouchers.service';

@Controller('gift-vouchers')
@UseGuards(AuthGuard)
export class GiftVouchersController {
  constructor(private readonly giftVouchersService: GiftVouchersService) {}

  @Post('redeem')
  async redeemVoucher(
    @Req() req: Request,
    @Body() dto: RedeemGiftVoucherDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.giftVouchersService.redeemVoucher({
      userId,
      code: dto.code,
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Get('admin')
  @UseGuards(SuperadminGuard)
  async listAdminVouchers(@Req() req: Request): Promise<object> {
    const data = await this.giftVouchersService.listAdminVouchers();
    return successResponse(
      {
        state: 'success',
        vouchers: data,
      },
      getCorrelationId(req),
    );
  }

  @Post('admin')
  @UseGuards(SuperadminGuard)
  async generateAdminVoucher(
    @Req() req: Request,
    @Body() dto: AdminGenerateGiftVoucherDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.giftVouchersService.generateAdminVouchers({
      actorUserId,
      creditAmount: dto.creditAmount,
      count: dto.count,
      expiresAt: dto.expiresAt,
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('admin/:voucherId/void')
  @UseGuards(SuperadminGuard)
  async voidAdminVoucher(
    @Req() req: Request,
    @Param('voucherId') voucherId: string,
    @Body() dto: AdminVoidGiftVoucherDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.giftVouchersService.voidVoucher({
      actorUserId,
      voucherId,
      reason: dto.reason,
    });
    return successResponse(data, getCorrelationId(req));
  }
}
