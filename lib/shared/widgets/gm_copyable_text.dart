import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// Text a person can select and copy, such as an address or a link the app
/// does not open. Copying starts with a long press on the text, so the line
/// is at least [gmTargetMin] tall, like every other control.
class GmCopyableText extends StatelessWidget {
  const new(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: gmTargetMin),
    child: SelectableText(text, style: style),
  );
}
