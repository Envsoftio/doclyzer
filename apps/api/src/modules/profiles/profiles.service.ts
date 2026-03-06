import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type { CreateProfileDto, UpdateProfileDto } from './profiles.dto';
import { ProfileLimitExceededException } from './exceptions/profile-limit-exceeded.exception';
import { ProfileNotFoundException } from './exceptions/profile-not-found.exception';
import type { Profile, ProfileWithActive } from './profiles.types';
import { EntitlementsService } from '../entitlements/entitlements.service';

@Injectable()
export class ProfilesService {
  constructor(private readonly entitlementsService: EntitlementsService) {}

  private readonly profiles = new Map<string, Profile[]>();
  private readonly activeProfileId = new Map<string, string>();

  getProfiles(userId: string): ProfileWithActive[] {
    const active = this.activeProfileId.get(userId);
    return (this.profiles.get(userId) ?? []).map((p) => ({
      ...p,
      isActive: p.id === active,
    }));
  }

  createProfile(userId: string, dto: CreateProfileDto): ProfileWithActive {
    const existing = this.profiles.get(userId) ?? [];
    const maxProfiles = this.entitlementsService.getMaxProfiles(userId);
    if (existing.length >= maxProfiles) {
      throw new ProfileLimitExceededException();
    }

    const id = randomUUID();
    const profile: Profile = {
      id,
      userId,
      name: dto.name,
      dateOfBirth: dto.dateOfBirth ?? null,
      relation: dto.relation ?? null,
      createdAt: new Date().toISOString(),
    };

    existing.push(profile);
    this.profiles.set(userId, existing);

    if (existing.length === 1) {
      this.activeProfileId.set(userId, id);
    }

    const active = this.activeProfileId.get(userId);
    return { ...profile, isActive: profile.id === active };
  }

  updateProfile(
    userId: string,
    profileId: string,
    dto: UpdateProfileDto,
  ): ProfileWithActive {
    const userProfiles = this.profiles.get(userId) ?? [];
    const index = userProfiles.findIndex((p) => p.id === profileId);

    if (index === -1) {
      throw new ProfileNotFoundException();
    }

    const existing = userProfiles[index];
    const updated: Profile = {
      ...existing,
      name: dto.name !== undefined ? dto.name : existing.name,
      dateOfBirth:
        dto.dateOfBirth !== undefined ? dto.dateOfBirth : existing.dateOfBirth,
      relation: dto.relation !== undefined ? dto.relation : existing.relation,
    };

    userProfiles[index] = updated;
    this.profiles.set(userId, userProfiles);

    const active = this.activeProfileId.get(userId);
    return { ...updated, isActive: updated.id === active };
  }

  activateProfile(userId: string, profileId: string): ProfileWithActive[] {
    const userProfiles = this.profiles.get(userId) ?? [];
    const found = userProfiles.find((p) => p.id === profileId);

    if (!found) {
      throw new ProfileNotFoundException();
    }

    this.activeProfileId.set(userId, profileId);
    return this.getProfiles(userId);
  }

  deleteProfile(userId: string, profileId: string): ProfileWithActive[] {
    const userProfiles = this.profiles.get(userId) ?? [];
    const index = userProfiles.findIndex((p) => p.id === profileId);

    if (index === -1) {
      throw new ProfileNotFoundException();
    }

    userProfiles.splice(index, 1);
    this.profiles.set(userId, userProfiles);

    if (this.activeProfileId.get(userId) === profileId) {
      if (userProfiles.length > 0) {
        this.activeProfileId.set(userId, userProfiles[0].id);
      } else {
        this.activeProfileId.delete(userId);
      }
    }

    return this.getProfiles(userId);
  }
}
