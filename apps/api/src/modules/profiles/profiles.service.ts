import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { isUUID } from 'class-validator';
import { Repository } from 'typeorm';
import { ProfileEntity } from '../../database/entities/profile.entity';
import type { CreateProfileDto, UpdateProfileDto } from './profiles.dto';
import { ProfileLimitExceededException } from './exceptions/profile-limit-exceeded.exception';
import { ProfileNotFoundException } from './exceptions/profile-not-found.exception';
import type { ProfileWithActive } from './profiles.types';
import { EntitlementsService } from '../entitlements/entitlements.service';

@Injectable()
export class ProfilesService {
  constructor(
    @InjectRepository(ProfileEntity)
    private readonly profileRepo: Repository<ProfileEntity>,
    private readonly entitlementsService: EntitlementsService,
  ) {}

  async getActiveProfileId(userId: string): Promise<string | null> {
    const active = await this.profileRepo.findOne({
      where: { userId, isActive: true },
      select: ['id'],
    });
    return active?.id ?? null;
  }

  /** Returns profile if user owns it; throws ProfileNotFoundException otherwise. */
  async getProfile(
    userId: string,
    profileId: string,
  ): Promise<ProfileWithActive> {
    if (!isUUID(profileId)) throw new ProfileNotFoundException();
    const entity = await this.profileRepo.findOne({
      where: { id: profileId, userId },
    });
    if (!entity) throw new ProfileNotFoundException();
    return this.toDto(entity);
  }

  async getProfiles(userId: string): Promise<ProfileWithActive[]> {
    const profiles = await this.profileRepo.find({
      where: { userId },
      order: { createdAt: 'ASC' },
    });
    return profiles.map((p) => this.toDto(p));
  }

  async createProfile(
    userId: string,
    dto: CreateProfileDto,
  ): Promise<ProfileWithActive> {
    const count = await this.profileRepo.count({ where: { userId } });
    const maxProfiles = await this.entitlementsService.getMaxProfiles(userId);
    if (count >= maxProfiles) throw new ProfileLimitExceededException();

    const isFirstProfile = count === 0;
    const entity = this.profileRepo.create({
      userId,
      name: dto.name,
      dateOfBirth: dto.dateOfBirth ?? null,
      relation: dto.relation ?? null,
      isActive: isFirstProfile,
    });
    const saved = await this.profileRepo.save(entity);
    return this.toDto(saved);
  }

  async updateProfile(
    userId: string,
    profileId: string,
    dto: UpdateProfileDto,
  ): Promise<ProfileWithActive> {
    if (!isUUID(profileId)) throw new ProfileNotFoundException();
    const entity = await this.profileRepo.findOne({
      where: { id: profileId, userId },
    });
    if (!entity) throw new ProfileNotFoundException();

    if (dto.name !== undefined) entity.name = dto.name;
    if (dto.dateOfBirth !== undefined) entity.dateOfBirth = dto.dateOfBirth;
    if (dto.relation !== undefined) entity.relation = dto.relation;

    const saved = await this.profileRepo.save(entity);
    return this.toDto(saved);
  }

  async activateProfile(
    userId: string,
    profileId: string,
  ): Promise<ProfileWithActive[]> {
    if (!isUUID(profileId)) throw new ProfileNotFoundException();
    const target = await this.profileRepo.findOne({
      where: { id: profileId, userId },
    });
    if (!target) throw new ProfileNotFoundException();

    await this.profileRepo.manager.transaction(async (manager) => {
      const repo = manager.getRepository(ProfileEntity);
      await repo.update({ userId }, { isActive: false });
      await repo.update({ id: profileId, userId }, { isActive: true });
    });

    return this.getProfiles(userId);
  }

  async deleteProfile(
    userId: string,
    profileId: string,
  ): Promise<ProfileWithActive[]> {
    if (!isUUID(profileId)) throw new ProfileNotFoundException();
    const entity = await this.profileRepo.findOne({
      where: { id: profileId, userId },
    });
    if (!entity) throw new ProfileNotFoundException();

    const wasActive = entity.isActive;
    await this.profileRepo.manager.transaction(async (manager) => {
      const repo = manager.getRepository(ProfileEntity);
      await repo.delete({ id: profileId, userId });

      if (!wasActive) return;

      const remaining = await repo.find({
        where: { userId },
        order: { createdAt: 'ASC' },
      });
      if (remaining.length > 0) {
        await repo.update(remaining[0].id, { isActive: true });
      }
    });

    return this.getProfiles(userId);
  }

  private toDto(e: ProfileEntity): ProfileWithActive {
    return {
      id: e.id,
      userId: e.userId,
      name: e.name,
      dateOfBirth: e.dateOfBirth,
      relation: e.relation,
      createdAt: e.createdAt.toISOString(),
      isActive: e.isActive,
    };
  }
}
