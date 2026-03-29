import { config } from 'dotenv';
import { join } from 'path';
import { DataSource } from 'typeorm';

// Load .env when running TypeORM CLI (migrations); Nest loads it via ConfigModule
config({ path: join(__dirname, '../../../../.env') });
import { AccountPreferenceEntity } from './entities/account-preference.entity';
import { ClosureRequestEntity } from './entities/closure-request.entity';
import { ConsentRecordEntity } from './entities/consent-record.entity';
import { DataExportRequestEntity } from './entities/data-export-request.entity';
import { ProfileEntity } from './entities/profile.entity';
import { ReportEntity } from './entities/report.entity';
import { ReportLabValueEntity } from './entities/report-lab-value.entity';
import { CreditPackEntity } from './entities/credit-pack.entity';
import { OrderEntity } from './entities/order.entity';
import { PlanEntity } from './entities/plan.entity';
import { PromoCodeEntity } from './entities/promo-code.entity';
import { PromoRedemptionEntity } from './entities/promo-redemption.entity';
import { SubscriptionEntity } from './entities/subscription.entity';
import { UserEntitlementEntity } from './entities/user-entitlement.entity';
import { RestrictionEntity } from './entities/restriction.entity';
import { SessionEntity } from './entities/session.entity';
import { UserEntity } from './entities/user.entity';
import { AnalyticsTaxonomyFieldEntity } from './entities/analytics-taxonomy-field.entity';
import { AnalyticsGovernanceReviewEntity } from './entities/analytics-governance-review.entity';
import { SuperadminActionAuditEventEntity } from './entities/superadmin-action-audit-event.entity';
import { migrations } from './migrations';

/**
 * Standalone DataSource for TypeORM CLI (migration:generate, migration:run, migration:revert).
 * NestJS DI is unavailable in CLI context — reads process.env directly.
 */
export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: [
    UserEntity,
    SessionEntity,
    ProfileEntity,
    AccountPreferenceEntity,
    RestrictionEntity,
    DataExportRequestEntity,
    ClosureRequestEntity,
    ConsentRecordEntity,
    ReportEntity,
    ReportLabValueEntity,
    PlanEntity,
    UserEntitlementEntity,
    CreditPackEntity,
    OrderEntity,
    PromoCodeEntity,
    PromoRedemptionEntity,
    SubscriptionEntity,
    AnalyticsTaxonomyFieldEntity,
    AnalyticsGovernanceReviewEntity,
    SuperadminActionAuditEventEntity,
  ],
  migrations,
  synchronize: false,
  logging: process.env.NODE_ENV === 'development',
});
