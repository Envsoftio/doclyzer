import { InitialSchema1730812800000 } from './1730812800000-InitialSchema';
import { AddDisplayName1730812900000 } from './1730812900000-AddDisplayName';
import { AddPolicyTypeToConsentRecords1730813000000 } from './1730813000000-AddPolicyTypeToConsentRecords';
import { AddAvatarUrl1730813100000 } from './1730813100000-AddAvatarUrl';
import { CreateReportsTable1730813200000 } from './1730813200000-CreateReportsTable';
import { AddContentHashToReports1730813300000 } from './1730813300000-AddContentHashToReports';
import { AddReportLabValuesTable1730813400000 } from './1730813400000-AddReportLabValuesTable';
import { AddSummaryToReports1730813500000 } from './1730813500000-AddSummaryToReports';
import { CreateReportProcessingAttemptsTable1730813600000 } from './1730813600000-CreateReportProcessingAttemptsTable';
import { AddParsedTranscriptToReports1730813700000 } from './1730813700000-AddParsedTranscriptToReports';
import { CreateShareLinksTable1730813800000 } from './1730813800000-CreateShareLinksTable';
import { AddExpiresAtToShareLinks1730813900000 } from './1730813900000-AddExpiresAtToShareLinks';
import { CreateUserSharePoliciesTable1730814000000 } from './1730814000000-CreateUserSharePoliciesTable';
import { CreateShareAccessEventsTable1730814100000 } from './1730814100000-CreateShareAccessEventsTable';
import { CreateBillingTables1730814200000 } from './1730814200000-CreateBillingTables';
import { CreateCreditPacksAndOrders1730814300000 } from './1730814300000-CreateCreditPacksAndOrders';
import { CreateSubscriptionsTable1730814400000 } from './1730814400000-CreateSubscriptionsTable';
import { CreatePromoCodesAndRedemptions1730814500000 } from './1730814500000-CreatePromoCodesAndRedemptions';
import { MigrateToBetterAuth1730814600000 } from './1730814600000-MigrateToBetterAuth';
import { RemovePasswordResetTokens1730814700000 } from './1730814700000-RemovePasswordResetTokens';
import { CreateSuperadminMfaAndAuditTables1730814800000 } from './1730814800000-CreateSuperadminMfaAndAuditTables';
import { CreatePlanConfigAuditAndVersioning1730814900000 } from './1730814900000-CreatePlanConfigAuditAndVersioning';
import { CreatePromoCodeAuditEvents1730815000000 } from './1730815000000-CreatePromoCodeAuditEvents';
import { CreateAnalyticsGovernanceTables1730815100000 } from './1730815100000-CreateAnalyticsGovernanceTables';
import { CreateSuperadminActionAuditTables1730815200000 } from './1730815200000-CreateSuperadminActionAuditTables';
import { FixAuditEventImmutabilityAndTamperChain1730815300000 } from './1730815300000-FixAuditEventImmutabilityAndTamperChain';
import { AddUserRoleColumn1730815400000 } from './1730815400000-AddUserRoleColumn';
import { CreateSuspiciousActivityQueue1730815500000 } from './1730815500000-CreateSuspiciousActivityQueue';
import { AddRestrictionReviewMode1730815600000 } from './1730815600000-AddRestrictionReviewMode';
import { CreateAccountOverridesTable1730815700000 } from './1730815700000-CreateAccountOverridesTable';
import { CreateCaseResolutionDocumentsTable1730815800000 } from './1730815800000-CreateCaseResolutionDocumentsTable';
import { CreateEmailAdminTables1730815900000 } from './1730815900000-CreateEmailAdminTables';
import { AddIdempotencyKeyToEmailQueue1730816000000 } from './1730816000000-AddIdempotencyKeyToEmailQueue';
import { AddGinIndexToDeliveryEventMetadata1730816100000 } from './1730816100000-AddGinIndexToDeliveryEventMetadata';
import { AddEntitlementChangeReasonToUserEntitlements1730816200000 } from './1730816200000-AddEntitlementChangeReasonToUserEntitlements';
import { CreateServiceIncidentsTable1730816300000 } from './1730816300000-CreateServiceIncidentsTable';
import { CreateSupportRequestsTable1730816400000 } from './1730816400000-CreateSupportRequestsTable';

export const migrations = [
  InitialSchema1730812800000,
  AddDisplayName1730812900000,
  AddPolicyTypeToConsentRecords1730813000000,
  AddAvatarUrl1730813100000,
  CreateReportsTable1730813200000,
  AddContentHashToReports1730813300000,
  AddReportLabValuesTable1730813400000,
  AddSummaryToReports1730813500000,
  CreateReportProcessingAttemptsTable1730813600000,
  AddParsedTranscriptToReports1730813700000,
  CreateShareLinksTable1730813800000,
  AddExpiresAtToShareLinks1730813900000,
  CreateUserSharePoliciesTable1730814000000,
  CreateShareAccessEventsTable1730814100000,
  CreateBillingTables1730814200000,
  CreateCreditPacksAndOrders1730814300000,
  CreateSubscriptionsTable1730814400000,
  CreatePromoCodesAndRedemptions1730814500000,
  MigrateToBetterAuth1730814600000,
  RemovePasswordResetTokens1730814700000,
  CreateSuperadminMfaAndAuditTables1730814800000,
  CreatePlanConfigAuditAndVersioning1730814900000,
  CreatePromoCodeAuditEvents1730815000000,
  CreateAnalyticsGovernanceTables1730815100000,
  CreateSuperadminActionAuditTables1730815200000,
  FixAuditEventImmutabilityAndTamperChain1730815300000,
  AddUserRoleColumn1730815400000,
  CreateSuspiciousActivityQueue1730815500000,
  AddRestrictionReviewMode1730815600000,
  CreateAccountOverridesTable1730815700000,
  CreateCaseResolutionDocumentsTable1730815800000,
  CreateEmailAdminTables1730815900000,
  AddIdempotencyKeyToEmailQueue1730816000000,
  AddGinIndexToDeliveryEventMetadata1730816100000,
  AddEntitlementChangeReasonToUserEntitlements1730816200000,
  CreateServiceIncidentsTable1730816300000,
  CreateSupportRequestsTable1730816400000,
];
