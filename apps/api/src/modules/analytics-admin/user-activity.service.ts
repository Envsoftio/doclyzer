import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { UserEntity } from '../../database/entities/user.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import {
  ReportEntity,
  type ReportStatus,
} from '../../database/entities/report.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import type { UserDirectoryQueryDto } from './analytics-admin.dto';

export interface UserActivityMetrics {
  totalUsers: number;
  activeUsersLast7Days: number;
  totalProfiles: number;
  reportsInPipeline: number;
  totalParsedReports: number;
  totalFailedReports: number;
}

export interface UserDirectoryItem {
  id: string;
  email: string;
  displayName: string | null;
  role: string;
  createdAt: string;
  profileCount: number;
  reportCount: number;
  lastLoginAt: string | null;
}

export interface UserDirectoryResult {
  users: UserDirectoryItem[];
  total: number;
  page: number;
  limit: number;
}

export interface UserWorkbench {
  user: {
    id: string;
    email: string;
    displayName: string | null;
    role: string;
    createdAt: string;
  };
  profiles: { id: string; name: string; createdAt: string; reportCount: number }[];
  reports: {
    id: string;
    profileId: string;
    originalFileName: string;
    sizeBytes: number;
    status: string;
    createdAt: string;
    updatedAt: string;
  }[];
  sessions: {
    id: string;
    ipAddress: string | null;
    userAgent: string | null;
    createdAt: string;
    expiresAt: string;
  }[];
  reportStatusSummary: Record<string, number>;
}

export interface FilePipelineStatus {
  statusCounts: Record<string, number>;
  totalInFlight: number;
  oldestInFlightCreatedAt: string | null;
}

const IN_FLIGHT_STATUSES: ReportStatus[] = ['uploading', 'queued', 'parsing'];
const FAILED_STATUSES: ReportStatus[] = ['failed_transient', 'failed_terminal'];

@Injectable()
export class UserActivityService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(ProfileEntity)
    private readonly profileRepo: Repository<ProfileEntity>,
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepo: Repository<SessionEntity>,
  ) {}

  async getUserActivityMetrics(): Promise<UserActivityMetrics> {
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

    const [totalUsers, totalProfiles, reportsInPipeline, totalParsedReports, totalFailedReports] =
      await Promise.all([
        this.userRepo.count(),
        this.profileRepo.count(),
        this.reportRepo.count({ where: { status: In(IN_FLIGHT_STATUSES) } }),
        this.reportRepo.count({ where: { status: 'parsed' } }),
        this.reportRepo.count({ where: { status: In(FAILED_STATUSES) } }),
      ]);

    const activeRow = await this.sessionRepo
      .createQueryBuilder('session')
      .select('COUNT(DISTINCT session.user_id)', 'count')
      .where('session.created_at >= :since', { since: sevenDaysAgo })
      .getRawOne();

    return {
      totalUsers,
      activeUsersLast7Days: Number(activeRow?.count ?? 0),
      totalProfiles,
      reportsInPipeline,
      totalParsedReports,
      totalFailedReports,
    };
  }

  async getUserDirectory(query: UserDirectoryQueryDto): Promise<UserDirectoryResult> {
    const page = query.page ?? 1;
    const limit = Math.min(query.limit ?? 50, 200);
    const sortBy = query.sortBy ?? 'createdAt';
    const sortDir = (query.sortDir ?? 'DESC').toUpperCase() as 'ASC' | 'DESC';
    const offset = (page - 1) * limit;

    const qb = this.userRepo
      .createQueryBuilder('u')
      .select('u.id', 'id')
      .addSelect('u.email', 'email')
      .addSelect('u.display_name', 'displayName')
      .addSelect('u.role', 'role')
      .addSelect('u.created_at', 'createdAt')
      .addSelect('COUNT(DISTINCT p.id)', 'profileCount')
      .addSelect('COUNT(DISTINCT r.id)', 'reportCount')
      .addSelect('MAX(s.created_at)', 'lastLoginAt')
      .leftJoin(ProfileEntity, 'p', 'p.user_id = u.id')
      .leftJoin(ReportEntity, 'r', 'r.user_id = u.id')
      .leftJoin(SessionEntity, 's', 's.user_id = u.id')
      .groupBy('u.id');

    if (query.search) {
      qb.where('u.email ILIKE :search', { search: `%${query.search}%` });
    }

    const countQb = this.userRepo
      .createQueryBuilder('u')
      .select('COUNT(u.id)', 'count');
    if (query.search) {
      countQb.where('u.email ILIKE :search', { search: `%${query.search}%` });
    }
    const countRow = await countQb.getRawOne();
    const total = Number(countRow?.count ?? 0);

    const orderColumn =
      sortBy === 'email'
        ? 'u.email'
        : sortBy === 'reportCount'
          ? '"reportCount"'
          : 'u.created_at';

    qb.orderBy(orderColumn, sortDir).offset(offset).limit(limit);

    const rows = await qb.getRawMany();

    const users: UserDirectoryItem[] = rows.map((row) => ({
      id: row.id,
      email: row.email,
      displayName: row.displayName ?? null,
      role: row.role,
      createdAt: row.createdAt instanceof Date ? row.createdAt.toISOString() : String(row.createdAt),
      profileCount: Number(row.profileCount ?? 0),
      reportCount: Number(row.reportCount ?? 0),
      lastLoginAt: row.lastLoginAt ? new Date(row.lastLoginAt).toISOString() : null,
    }));

    return { users, total, page, limit };
  }

  async getUserWorkbench(userId: string): Promise<UserWorkbench> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException({ code: 'USER_NOT_FOUND', message: 'User not found' });

    const [profiles, reports, sessions] = await Promise.all([
      this.profileRepo.find({ where: { userId }, order: { createdAt: 'ASC' } }),
      this.reportRepo.find({ where: { userId }, order: { createdAt: 'DESC' } }),
      this.sessionRepo.find({ where: { userId }, order: { createdAt: 'DESC' }, take: 50 }),
    ]);

    // Profile report counts
    const profileReportCounts = new Map<string, number>();
    for (const r of reports) {
      profileReportCounts.set(r.profileId, (profileReportCounts.get(r.profileId) ?? 0) + 1);
    }

    // Report status summary
    const reportStatusSummary: Record<string, number> = {};
    for (const r of reports) {
      reportStatusSummary[r.status] = (reportStatusSummary[r.status] ?? 0) + 1;
    }

    return {
      user: {
        id: user.id,
        email: user.email,
        displayName: user.displayName ?? null,
        role: user.role,
        createdAt: user.createdAt.toISOString(),
      },
      profiles: profiles.map((p) => ({
        id: p.id,
        name: p.name,
        createdAt: p.createdAt.toISOString(),
        reportCount: profileReportCounts.get(p.id) ?? 0,
      })),
      reports: reports.map((r) => ({
        id: r.id,
        profileId: r.profileId,
        originalFileName: r.originalFileName,
        sizeBytes: r.sizeBytes,
        status: r.status,
        createdAt: r.createdAt.toISOString(),
        updatedAt: r.updatedAt.toISOString(),
      })),
      sessions: sessions.map((s) => ({
        id: s.id,
        ipAddress: s.ipAddress ?? null,
        userAgent: s.userAgent ?? null,
        createdAt: s.createdAt.toISOString(),
        expiresAt: s.expiresAt.toISOString(),
      })),
      reportStatusSummary,
    };
  }

  async getFilePipelineStatus(): Promise<FilePipelineStatus> {
    const rows = await this.reportRepo
      .createQueryBuilder('r')
      .select('r.status', 'status')
      .addSelect('COUNT(r.id)', 'count')
      .groupBy('r.status')
      .getRawMany();

    const statusCounts: Record<string, number> = {};
    for (const row of rows) {
      statusCounts[row.status] = Number(row.count);
    }

    const totalInFlight = IN_FLIGHT_STATUSES.reduce(
      (sum, s) => sum + (statusCounts[s] ?? 0),
      0,
    );

    const oldestRow = await this.reportRepo
      .createQueryBuilder('r')
      .select('MIN(r.created_at)', 'oldest')
      .where('r.status IN (:...statuses)', { statuses: IN_FLIGHT_STATUSES })
      .getRawOne();

    const oldestInFlightCreatedAt = oldestRow?.oldest
      ? new Date(oldestRow.oldest).toISOString()
      : null;

    return { statusCounts, totalInFlight, oldestInFlightCreatedAt };
  }
}
