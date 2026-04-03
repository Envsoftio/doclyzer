import 'support_models.dart';

abstract class SupportRepository {
  Future<SupportRequestResult> createSupportRequest(
    SupportRequestPayload payload,
  );
}
