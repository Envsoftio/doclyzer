import 'dart:io';
import 'dart:math';

import '../../core/api_client.dart';

enum SupportActionType {
  auth,
  reportUpload,
  reportParse,
  shareLinkCreate,
  shareLinkRevoke,
  billingEntitlement,
  billingCheckout,
  notificationPreferences,
  accountProfileUpdate,
}

String supportActionTypeValue(SupportActionType type) {
  return switch (type) {
    SupportActionType.auth => 'auth',
    SupportActionType.reportUpload => 'report_upload',
    SupportActionType.reportParse => 'report_parse',
    SupportActionType.shareLinkCreate => 'share_link_create',
    SupportActionType.shareLinkRevoke => 'share_link_revoke',
    SupportActionType.billingEntitlement => 'billing_entitlement',
    SupportActionType.billingCheckout => 'billing_checkout',
    SupportActionType.notificationPreferences => 'notification_preferences',
    SupportActionType.accountProfileUpdate => 'account_profile_update',
  };
}

class SupportRequestMetadata {
  const SupportRequestMetadata({
    this.appVersion,
    this.platform,
    this.surface,
  });

  final String? appVersion;
  final String? platform;
  final String? surface;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (appVersion != null && appVersion!.isNotEmpty) {
      data['appVersion'] = appVersion;
    }
    if (platform != null && platform!.isNotEmpty) {
      data['platform'] = platform;
    }
    if (surface != null && surface!.isNotEmpty) {
      data['surface'] = surface;
    }
    return data;
  }
}

class SupportRequestContext {
  const SupportRequestContext({
    required this.actionType,
    this.correlationId,
    this.clientActionId,
    this.errorCode,
    this.entityIds,
    this.metadata,
  });

  final SupportActionType actionType;
  final String? correlationId;
  final String? clientActionId;
  final String? errorCode;
  final Map<String, String>? entityIds;
  final SupportRequestMetadata? metadata;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'actionType': supportActionTypeValue(actionType),
    };
    if (correlationId != null && correlationId!.isNotEmpty) {
      data['correlationId'] = correlationId;
    }
    if (clientActionId != null && clientActionId!.isNotEmpty) {
      data['clientActionId'] = clientActionId;
    }
    if (errorCode != null && errorCode!.isNotEmpty) {
      data['errorCode'] = errorCode;
    }
    if (entityIds != null && entityIds!.isNotEmpty) {
      data['entityIds'] = entityIds;
    }
    final metadataJson = metadata?.toJson();
    if (metadataJson != null && metadataJson.isNotEmpty) {
      data['metadata'] = metadataJson;
    }
    return data;
  }
}

class SupportRequestPayload {
  const SupportRequestPayload({
    required this.context,
    this.userMessage,
    this.errorMessage,
  });

  final SupportRequestContext context;
  final String? userMessage;
  final String? errorMessage;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'context': context.toJson(),
    };
    if (userMessage != null && userMessage!.trim().isNotEmpty) {
      data['userMessage'] = userMessage!.trim();
    }
    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      data['errorMessage'] = errorMessage!.trim();
    }
    return data;
  }
}

class SupportRequestResult {
  const SupportRequestResult({required this.id, required this.correlationId});

  final String id;
  final String correlationId;
}

SupportRequestContext buildSupportRequestContext({
  required SupportActionType actionType,
  ApiException? apiException,
  Map<String, String>? entityIds,
  String? correlationIdOverride,
}) {
  final correlationId =
      apiException?.data?['correlationId'] as String? ?? correlationIdOverride;
  final clientActionId =
      correlationId == null ? _generateClientActionId() : null;

  return SupportRequestContext(
    actionType: actionType,
    correlationId: correlationId,
    clientActionId: clientActionId,
    errorCode: apiException?.code,
    entityIds: entityIds,
    metadata: SupportRequestMetadata(
      platform: Platform.operatingSystem,
      surface: 'mobile_app',
    ),
  );
}

String _generateClientActionId() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  return _formatUuid(bytes);
}

String _formatUuid(List<int> bytes) {
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
  return '${hex.sublist(0, 4).join()}-'
      '${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-'
      '${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10, 16).join()}';
}
