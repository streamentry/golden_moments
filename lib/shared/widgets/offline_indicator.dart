import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/services/connectivity_service.dart';
import 'package:golden_moments/design_system.dart';

/// Widget that displays connectivity status and offline indicators
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({
    super.key,
    this.showWhenOnline = false,
    this.compact = false,
  });

  final bool showWhenOnline;
  final bool compact;

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  ConnectivityStatus _status = ConnectivityStatus.unknown;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();
    if (!mounted) return;
    setState(() {
      _status = _connectivityService.currentStatus;
    });

    _connectivityService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if online and showWhenOnline is false
    if (_status == ConnectivityStatus.connected && !widget.showWhenOnline) {
      return const SizedBox.shrink();
    }

    return widget.compact ? _buildCompactIndicator() : _buildFullIndicator();
  }

  Widget _buildCompactIndicator() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: gmSpaceSm,
        vertical: gmSpaceXs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(theme),
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 20, color: _getIconColor(theme)),
          const SizedBox(width: gmSpaceXs),
          Flexible(
            child: Text(
              _getStatusText(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getIconColor(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullIndicator() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(gmSpaceMd),
      decoration: BoxDecoration(
        color: _getStatusColor(theme),
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), size: 24, color: _getIconColor(theme)),
          const SizedBox(width: gmSpaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getIconColor(theme),
                  ),
                ),
                if (_getStatusDescription().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getStatusDescription(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (_status == ConnectivityStatus.disconnected)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _getIconColor(theme),
              ),
              onPressed: () async {
                await _connectivityService.checkConnectivity();
              },
              child: const Text('Try again'),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return Icons.help_outline;
      case ConnectivityStatus.connected:
        return Icons.wifi;
      case ConnectivityStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return 'Unknown';
      case ConnectivityStatus.connected:
        return 'Online';
      case ConnectivityStatus.disconnected:
        return 'Offline';
    }
  }

  String _getStatusTitle() {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return 'Connection status unknown';
      case ConnectivityStatus.connected:
        return 'Connected to the internet';
      case ConnectivityStatus.disconnected:
        return 'No internet connection';
    }
  }

  String _getStatusDescription() {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return 'Checking connection status...';
      case ConnectivityStatus.connected:
        // There is no account or sync in this release, so do not promise it.
        return 'You can download new packs.';
      case ConnectivityStatus.disconnected:
        return 'Downloaded packs still work.';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return gmSurf200;
      case ConnectivityStatus.connected:
        return gmGreen600.withValues(alpha: 0.1);
      case ConnectivityStatus.disconnected:
        return gmOrange600.withValues(alpha: 0.1);
    }
  }

  Color _getIconColor(ThemeData theme) {
    switch (_status) {
      // Offline is "needs attention" (warning), not a failure: downloaded
      // packs keep working. Driftwood is below 4.5:1 for text; use Walnut.
      case ConnectivityStatus.unknown:
        return theme.colorScheme.onSurfaceVariant;
      case ConnectivityStatus.connected:
        return gmGreen600;
      case ConnectivityStatus.disconnected:
        return gmOrange600;
    }
  }
}

/// Banner widget that appears at the top when offline
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeConnectivity();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();
    if (!mounted) return;
    _updateStatus(_connectivityService.currentStatus);

    _connectivityService.statusStream.listen((status) {
      if (mounted) {
        _updateStatus(status);
      }
    });
  }

  void _updateStatus(ConnectivityStatus status) {
    final wasOffline = _status == ConnectivityStatus.disconnected;
    final isOffline = status == ConnectivityStatus.disconnected;

    setState(() {
      _status = status;
    });

    if (isOffline && !wasOffline) {
      _animationController.forward();
    } else if (!isOffline && wasOffline) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status != ConnectivityStatus.disconnected) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: gmSpaceMd,
          vertical: gmSpaceSm,
        ),
        // Warning, not error: being offline is not a failure because
        // downloaded packs keep working. White on Amber Clay is 6.8:1.
        color: gmOrange600,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, size: 24, color: Colors.white),
              const SizedBox(width: gmSpaceSm),
              Expanded(
                child: Text(
                  "You're offline. Downloaded packs still work.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () async {
                  await _connectivityService.checkConnectivity();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Connectivity status cubit for global state management
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit() : super(ConnectivityStatus.unknown) {
    _initialize();
  }

  final ConnectivityService _connectivityService = ConnectivityService.instance;

  Future<void> _initialize() async {
    await _connectivityService.initialize();
    emit(_connectivityService.currentStatus);

    _connectivityService.statusStream.listen(emit);
  }

  /// Manually check connectivity
  Future<void> checkConnectivity() async {
    final status = await _connectivityService.checkConnectivity();
    emit(status);
  }

  /// Get connectivity quality
  Future<ConnectivityQuality> getConnectivityQuality() async {
    return _connectivityService.getConnectivityQuality();
  }

  /// Check if connection is metered
  Future<bool> isConnectionMetered() async {
    return _connectivityService.isConnectionMetered();
  }
}
