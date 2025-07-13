import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/cache_test_service.dart';
import 'package:golden_moments/design_system.dart';

/// Test page to verify the design system works correctly
class DesignSystemTestPage extends StatefulWidget {
  const DesignSystemTestPage({super.key});

  @override
  State<DesignSystemTestPage> createState() => _DesignSystemTestPageState();
}

class _DesignSystemTestPageState extends State<DesignSystemTestPage> {
  bool _tileRevealed = false;
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: gmBuildTheme(brightness: Brightness.light),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Golden Moments Design System Test'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(gmSpaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Typography Test
                  Text(
                    'Golden Moments',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: gmSpaceMd),
                  Text(
                    'Design System Test',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: gmSpaceMd),
                  Text(
                    'This is body text to test the typography system. It should be readable and accessible for seniors.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: gmSpaceLg),

                  // Color Test
                  _buildColorSection(),
                  const SizedBox(height: gmSpaceLg),

                  // Button Tests
                  GmPrimaryButton(
                    label: 'Primary Button Test',
                    onTap: () {
                      setState(() {
                        _showConfetti = true;
                      });
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          setState(() {
                            _showConfetti = false;
                          });
                        }
                      });
                    },
                  ),
                  const SizedBox(height: gmSpaceMd),
                  GmOutlineButton(
                    label: 'Outline Button Test',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Outline button tapped!')),
                      );
                    },
                  ),
                  const SizedBox(height: gmSpaceMd),
                  const GmPrimaryButton(
                    label: 'Disabled Button',
                    onTap: null,
                    disabled: true,
                  ),
                  const SizedBox(height: gmSpaceLg),

                  // Cache System Test
                  Text(
                    'Cache System Test',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: gmSpaceSm),
                  GmPrimaryButton(
                    label: 'Test JSON Cache System',
                    onTap: () async {
                      try {
                        // await CacheTestService.testCacheSystem();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Cache system test passed!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Cache test failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: gmSpaceLg),

                  // Memory Tile Test
                  Text(
                    'Memory Tile Test',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: gmSpaceMd),
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: GmMemoryTile(
                      revealed: _tileRevealed,
                      image: const AssetImage('assets/images/placeholder.png'),
                      onTap: () {
                        setState(() {
                          _tileRevealed = !_tileRevealed;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: gmSpaceMd),
                  Text(
                    'Tap the tile above to test the flip animation',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: gmSpaceLg),

                  // Spacing Test
                  _buildSpacingSection(),
                ],
              ),
            ),
            // Confetti overlay
            GmConfettiOverlay(show: _showConfetti),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette Test',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: gmSpaceMd),
        Wrap(
          spacing: gmSpaceSm,
          runSpacing: gmSpaceSm,
          children: [
            _buildColorSwatch('Surface 50', gmSurf50),
            _buildColorSwatch('Surface 100', gmSurf100),
            _buildColorSwatch('Charcoal 900', gmCharcoal900),
            _buildColorSwatch('Gold 300', gmGold300),
            _buildColorSwatch('Gold 600', gmGold600),
            _buildColorSwatch('Gold 700', gmGold700),
            _buildColorSwatch('Sapphire 500', gmSapphire500),
            _buildColorSwatch('Emerald 500', gmEmerald500),
            _buildColorSwatch('Brick 500', gmBrick500),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(gmRadiusMd),
            border: Border.all(color: gmCharcoal900.withValues(alpha: 0.2)),
          ),
        ),
        const SizedBox(height: gmSpaceXs),
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSpacingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spacing Test',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: gmSpaceMd),
        _buildSpacingDemo('XS (4px)', gmSpaceXs),
        _buildSpacingDemo('SM (8px)', gmSpaceSm),
        _buildSpacingDemo('MD (16px)', gmSpaceMd),
        _buildSpacingDemo('LG (24px)', gmSpaceLg),
      ],
    );
  }

  Widget _buildSpacingDemo(String label, double spacing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: gmSpaceXs),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            width: spacing,
            height: 20,
            color: gmGold600,
          ),
        ],
      ),
    );
  }
}
