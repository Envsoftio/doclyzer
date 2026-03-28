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
];
