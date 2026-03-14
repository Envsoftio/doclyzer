import { InitialSchema1730812800000 } from './1730812800000-InitialSchema';
import { AddDisplayName1730812900000 } from './1730812900000-AddDisplayName';
import { AddPolicyTypeToConsentRecords1730813000000 } from './1730813000000-AddPolicyTypeToConsentRecords';
import { AddAvatarUrl1730813100000 } from './1730813100000-AddAvatarUrl';
import { CreateReportsTable1730813200000 } from './1730813200000-CreateReportsTable';

export const migrations = [
  InitialSchema1730812800000,
  AddDisplayName1730812900000,
  AddPolicyTypeToConsentRecords1730813000000,
  AddAvatarUrl1730813100000,
  CreateReportsTable1730813200000,
];
