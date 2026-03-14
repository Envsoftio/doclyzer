import 'package:mocktail/mocktail.dart';

import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/communication_preferences_repository.dart';
import 'package:mobile/features/account/data_rights_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/auth/auth_repository.dart';
import 'package:mobile/features/auth/sessions_repository.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockProfilesRepository extends Mock implements ProfilesRepository {}

class MockSessionsRepository extends Mock implements SessionsRepository {}

class MockCommunicationPreferencesRepository extends Mock
    implements CommunicationPreferencesRepository {}

class MockDataRightsRepository extends Mock implements DataRightsRepository {}

class MockRestrictionRepository extends Mock implements RestrictionRepository {}

class MockReportsRepository extends Mock implements ReportsRepository {}
