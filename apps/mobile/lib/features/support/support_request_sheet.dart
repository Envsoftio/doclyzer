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
    text: _buildPrefillText(supportContext, errorMessage),
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
                  'Request support',
                  style: Theme.of(ctx).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We will include diagnostic IDs so the team can investigate.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What happened? (optional)',
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
                              'Support request sent.',
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
                      : const Text('Send request'),
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
  SupportRequestContext context,
  String? errorMessage,
) {
  final buffer = StringBuffer();
  buffer.writeln('Action: ${supportActionTypeValue(context.actionType)}');
  if (context.correlationId != null && context.correlationId!.isNotEmpty) {
    buffer.writeln('Correlation ID: ${context.correlationId}');
  }
  if (context.clientActionId != null && context.clientActionId!.isNotEmpty) {
    buffer.writeln('Client Action ID: ${context.clientActionId}');
  }
  if (context.errorCode != null && context.errorCode!.isNotEmpty) {
    buffer.writeln('Error Code: ${context.errorCode}');
  }
  if (errorMessage != null && errorMessage.trim().isNotEmpty) {
    buffer.writeln('Error: ${errorMessage.trim()}');
  }
  buffer.writeln('');
  buffer.write('Additional details: ');
  return buffer.toString();
}
