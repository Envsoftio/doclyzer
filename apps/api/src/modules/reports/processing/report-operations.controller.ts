import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Req,
  UseGuards,
  BadRequestException,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { randomUUID } from 'node:crypto';
import type { Request } from 'express';
import { isUUID } from 'class-validator';
import { AuthGuard } from '../../../common/guards/auth.guard';
import { SuperadminGuard } from '../../auth/superadmin.guard';
import {
  cancelReportProcessing,
  retryReportProcessing,
} from './report-lifecycle';
import { processingSettings } from './processing-settings';
@Controller('health/report-processing')
export class ReportProcessHealthController {
  constructor(
    private readonly db: DataSource,
    private readonly config: ConfigService,
  ) {}
  @Get() async health() {
    if (!processingSettings(this.config).runtime) return { enabled: false };
    const rows = await this.db.query(
      "SELECT DISTINCT role FROM report_process_health WHERE heartbeat_at>clock_timestamp()-interval '30 seconds'",
    );
    const healthy = ['worker', 'dispatcher'].every((role) =>
      rows.some((r: { role: string }) => r.role === role),
    );
    if (!healthy)
      throw new ServiceUnavailableException({
        code: 'REPORT_PROCESSORS_UNAVAILABLE',
      });
    return { enabled: true, healthy: true };
  }
}
@Controller('admin/report-processing')
@UseGuards(AuthGuard, SuperadminGuard)
export class ReportOperationsController {
  constructor(
    private readonly db: DataSource,
    private readonly config: ConfigService,
  ) {}
  @Get() async metrics() {
    return {
      data: {
        jobs: await this.db.query(
          `SELECT state,count(*)::integer AS count,min(created_at) AS oldest FROM report_processing_jobs GROUP BY state`,
        ),
        deliveries: await this.db.query(
          `SELECT state,channel,count(*)::integer AS count,min(available_at) AS oldest FROM report_delivery_intents GROUP BY state,channel`,
        ),
        processes: await this.db.query(
          'SELECT role,max(heartbeat_at) AS heartbeat FROM report_process_health GROUP BY role',
        ),
        leases: await this.db.query(
          "SELECT count(*)::integer AS expired FROM report_processing_jobs WHERE state='leased' AND lease_expires_at<clock_timestamp()",
        ),
        orphans: await this.db.query(
          "SELECT state,count(*)::integer AS count,min(created_at) AS oldest FROM report_upload_intents WHERE state<>'accepted' GROUP BY state",
        ),
      },
    };
  }
  @Post(':id/:action') async operate(
    @Param('id') id: string,
    @Param('action') action: string,
    @Body() body: { reason?: string },
    @Req() req: Request,
  ) {
    if (
      !isUUID(id) ||
      !['retry', 'cancel'].includes(action) ||
      !body.reason?.trim() ||
      body.reason.length > 512
    )
      throw new BadRequestException();
    const [report] = await this.db.query(
      'SELECT user_id FROM reports WHERE id=$1',
      [id],
    );
    if (!report) throw new NotFoundException();
    const audit = randomUUID();
    await this.db.query(
      "INSERT INTO report_operator_actions(id,actor_user_id,report_id,action,reason,outcome) VALUES($1,$2,$3,$4,$5,'requested')",
      [audit, (req.user as { id: string }).id, id, action, body.reason],
    );
    try {
      if (action === 'retry')
        await retryReportProcessing(
          this.db,
          report.user_id,
          id,
          processingSettings(this.config).policy,
        );
      else await cancelReportProcessing(this.db, report.user_id, id, false);
      await this.db.query(
        "UPDATE report_operator_actions SET outcome='succeeded' WHERE id=$1",
        [audit],
      );
      return { data: { auditId: audit } };
    } catch (error) {
      await this.db.query(
        "UPDATE report_operator_actions SET outcome='failed' WHERE id=$1",
        [audit],
      );
      throw error;
    }
  }
}
