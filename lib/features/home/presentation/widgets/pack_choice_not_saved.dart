import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// Calm, persistent note when a favorite or hide choice could not be saved.
class PackChoiceNotSaved extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: gmSpaceSm),
        Expanded(
          child: Text(
            'Your choice could not be saved. It will apply until you close '
            'the app.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
