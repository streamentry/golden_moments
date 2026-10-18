import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

/// Page to display all packs for a given category
class PackPage extends StatefulWidget {
  const new({
    required this.categoryId,
    required this.categoryName,
    this.onPackTap,
    super.key,
  });

  final String categoryName;
  final String categoryId;
  final void Function(Pack pack)? onPackTap;

  @override
  State<PackPage> createState() => _PackPageState();
}

class _PackPageState extends State<PackPage> {
  List<Pack> _packs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchPacks());
  }

  Future<void> _fetchPacks() async {
    final packs = await LocalPackService().getPacksByCategory(
      widget.categoryId,
    );
    if (!mounted) return;
    setState(() {
      // Example: filter packs by categoryName, replace with real fetch
      _packs = packs.where((p) => p.category == widget.categoryId).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        unawaited(SoundService().playTap());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.categoryName)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _packs.isEmpty
            ? _EmptyState()
            : LayoutBuilder(
                builder: (context, constraints) {
                  // One centered column no wider than gmContentMaxWidth;
                  // extra width becomes margin.
                  final width = math.min(
                    constraints.maxWidth - gmSpaceMd * 2,
                    gmContentMaxWidth,
                  );
                  final side = (constraints.maxWidth - width) / 2;
                  final columns = (width / 170).floor().clamp(1, 4);
                  final cardWidth =
                      (width - (columns - 1) * gmSpaceSm) / columns;
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: side,
                      vertical: gmSpaceMd,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: PackCard.gridExtent(context, cardWidth),
                      crossAxisSpacing: gmSpaceSm,
                      mainAxisSpacing: gmSpaceSm,
                    ),
                    itemCount: _packs.length,
                    itemBuilder: (context, index) {
                      final pack = _packs[index];
                      return PackCard(
                        pack: pack,
                        onTap: widget.onPackTap == null
                            ? null
                            : () => widget.onPackTap?.call(pack),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'No packs found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'There are no packs in this category yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
