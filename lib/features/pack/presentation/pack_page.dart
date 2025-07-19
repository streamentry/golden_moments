import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

/// Page to display all packs for a given category
class PackPage extends StatefulWidget {
  const PackPage({
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
    _fetchPacks();
  }

  Future<void> _fetchPacks() async {
    final packs = await LocalPackService().getPacksByCategory(
      widget.categoryId,
    );
    setState(() {
      // Example: filter packs by categoryName, replace with real fetch
      _packs = packs.where((p) => p.category == widget.categoryId).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _packs.isEmpty
          ? _EmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(gmSpaceMd),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
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
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_off,
              size: 48,
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'No packs found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'There are no packs in this category yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
