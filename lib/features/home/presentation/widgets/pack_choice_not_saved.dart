import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';

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
            context.l10n.libraryChoiceNotSaved,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Calm, persistent note when the saved favorites and hidden packs could not
/// be read. They are left exactly as they are, never written over.
class PackChoicesUnreadable extends StatelessWidget {
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
            context.l10n.libraryChoicesUnreadable,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Shown while the saved choices are still loading: topics only, so a pack
/// marked Not for me never appears, even briefly.
class PackChoicesLoading extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.hourglass_empty, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: gmSpaceSm),
        Expanded(
          child: Text(
            context.l10n.libraryChoicesLoading,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
