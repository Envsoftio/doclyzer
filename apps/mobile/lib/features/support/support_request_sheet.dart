import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../core/feedback/status_messenger.dart';
import 'support_models.dart';
import 'support_repository.dart';

Future<void> showSupportRequestSheet({
  required BuildContext context,
  required SupportRepository supportRepository,
  required SupportRequestContext supportContext,
  String? errorMessage,
}) async {
  final controller = TextEditingController(
    text: _buildPrefillText(context, supportContext, errorMessage),
  );
  String? errorText;
  bool submitting = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.uiRequestSupport,
                  style: Theme.of(ctx).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.uiWeWillIncludeDiagnosticIDsSoThe,
                  style: Theme.of(ctx).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: context.l10n.uiWhatHappenedOptional,
                    alignLabelWithHint: true,
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorText!,
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setState(() {
                            submitting = true;
                            errorText = null;
                          });
                          try {
                            await supportRepository.createSupportRequest(
                              SupportRequestPayload(
                                context: supportContext,
                                userMessage: controller.text,
                                errorMessage: errorMessage,
                              ),
                            );
                            if (!ctx.mounted) return;
                            Navigator.of(ctx).pop();
                            StatusMessenger.showSuccess(
                              context,
                              context.l10n.uiSupportRequestSent,
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            setState(() {
                              submitting = false;
                              errorText = e.toString().replaceFirst(
                                'Exception: ',
                                '',
                              );
                            });
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.uiSendRequest),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  controller.dispose();
}

String _buildPrefillText(
  BuildContext buildContext,
  SupportRequestContext supportContext,
  String? errorMessage,
) {
  final buffer = StringBuffer();
  buffer.writeln(
    buildContext.l10n.uiSupportAction(
      supportActionTypeValue(supportContext.actionType),
    ),
  );
  if (supportContext.correlationId != null &&
      supportContext.correlationId!.isNotEmpty) {
    buffer.writeln(
      buildContext.l10n.uiSupportCorrelationId(supportContext.correlationId!),
    );
  }
  if (supportContext.clientActionId != null &&
      supportContext.clientActionId!.isNotEmpty) {
    buffer.writeln(
      buildContext.l10n.uiSupportClientActionId(supportContext.clientActionId!),
    );
  }
  if (supportContext.errorCode != null &&
      supportContext.errorCode!.isNotEmpty) {
    buffer.writeln(
      buildContext.l10n.uiSupportErrorCode(supportContext.errorCode!),
    );
  }
  if (errorMessage != null && errorMessage.trim().isNotEmpty) {
    buffer.writeln(buildContext.l10n.uiSupportError(errorMessage.trim()));
  }
  buffer.writeln('');
  buffer.write(buildContext.l10n.uiAdditionalDetails);
  return buffer.toString();
}
