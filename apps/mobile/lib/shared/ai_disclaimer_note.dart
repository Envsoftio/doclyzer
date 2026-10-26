import 'package:flutter/material.dart';

class AiDisclaimerNote extends StatelessWidget {
  const AiDisclaimerNote({super.key});

  static const String copy =
      'Doclyzer helps you organize and better understand your health reports. '
      'The information provided is for educational purposes only and is not '
      'medical advice, diagnosis, or treatment. Always consult a qualified '
      'healthcare professional for medical guidance.';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            copy,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
