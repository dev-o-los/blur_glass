import 'package:flutter/material.dart';

/// Dialog navigation buttons with Apple-style primary gradient.
class WizardFooter extends StatelessWidget {
  const WizardFooter({
    super.key,
    required this.showBack,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
  });

  final bool showBack;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool primaryEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          OutlinedButton(
            onPressed: () => Navigator.maybeOf(context)?.maybePop(),
            child: const Text('Back'),
          ),
        const Spacer(),
        FilledButton(
          onPressed: primaryEnabled ? onPrimary : null,
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}
