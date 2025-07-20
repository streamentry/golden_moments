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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(theme),
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: _getIconColor(theme),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getIconColor(theme),
              fontWeight: FontWeight.w600,
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
          Icon(
            _getStatusIcon(),
            size: 24,
            color: _getIconColor(theme),
          ),
          const SizedBox(width: gmSpaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getIconColor(theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_getStatusDescription().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getStatusDescription(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getIconColor(theme).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_status == ConnectivityStatus.disconnected)
            TextButton(
              onPressed: () async {
                await _connectivityService.checkConnectivity();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: _getIconColor(theme),
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        return 'Connection Status Unknown';
      case ConnectivityStatus.connected:
        return 'Connected to Internet';
      case ConnectivityStatus.disconnected:
        return 'No Internet Connection';
    }
  }

  String _getStatusDescription() {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return 'Checking connection status...';
      case ConnectivityStatus.connected:
        return 'You can download new packs and sync your progress';
      case ConnectivityStatus.disconnected:
        return 'You can still play with cached packs';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return theme.colorScheme.outline.withValues(alpha: 0.1);
      case ConnectivityStatus.connected:
        return gmGreen600.withValues(alpha: 0.1);
      case ConnectivityStatus.disconnected:
        return theme.colorScheme.error.withValues(alpha: 0.1);
    }
  }

  Color _getIconColor(ThemeData theme) {
    switch (_status) {
      case ConnectivityStatus.unknown:
        return theme.colorScheme.outline;
      case ConnectivityStatus.connected:
        return gmGreen600;
      case ConnectivityStatus.disconnected:
        return theme.colorScheme.error;
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
    _slideAnimation =
        Tween<double>(
          begin: -1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
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
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                size: 20,
                color: theme.colorScheme.onError,
              ),
              const SizedBox(width: gmSpaceSm),
              Expanded(
                child: Text(
                  'You\'re offline. Playing with cached packs only.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _connectivityService.checkConnectivity();
                },
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

    _connectivityService.statusStream.listen((status) {
      emit(status);
    });
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
