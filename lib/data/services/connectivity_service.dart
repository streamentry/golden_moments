import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/storage/browser_image_store.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  new _();

  static final instance = ConnectivityService._();

  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  Timer? _connectivityTimer;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Check if device is currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.connected;

  /// Check if device is currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.disconnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial status
    await _checkConnectivity();

    // Start periodic connectivity checks
    _connectivityTimer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectivity(),
    );
  }

  /// Dispose connectivity service
  void dispose() {
    _connectivityTimer?.cancel();
    unawaited(_statusController.close());
  }

  /// Manually check connectivity status
  Future<ConnectivityStatus> checkConnectivity() async {
    await _checkConnectivity();
    return _currentStatus;
  }

  /// Check connectivity and update status
  Future<void> _checkConnectivity() async {
    if (kIsWeb) {
      final status = BrowserImageStore.isOnline
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected;
      if (status != _currentStatus) {
        _currentStatus = status;
        _statusController.add(status);
      }
      return;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      final newStatus = result.isNotEmpty && result[0].rawAddress.isNotEmpty
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected;

      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _statusController.add(_currentStatus);
      }
    } on Object {
      if (_currentStatus != ConnectivityStatus.disconnected) {
        _currentStatus = ConnectivityStatus.disconnected;
        _statusController.add(_currentStatus);
      }
    }
  }

  /// Check if specific URL is reachable
  Future<bool> canReachUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final result = await InternetAddress.lookup(uri.host)
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }

  /// Get connectivity quality (basic implementation)
  Future<ConnectivityQuality> getConnectivityQuality() async {
    if (!isOnline) return ConnectivityQuality.none;

    try {
      final stopwatch = Stopwatch()..start();
      await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      stopwatch.stop();

      final latency = stopwatch.elapsedMilliseconds;

      if (latency < 100) return ConnectivityQuality.excellent;
      if (latency < 300) return ConnectivityQuality.good;
      if (latency < 1000) return ConnectivityQuality.fair;
      return ConnectivityQuality.poor;
    } on Object {
      return ConnectivityQuality.poor;
    }
  }

  /// Check if connection is metered (placeholder - would need platform-
  /// specific implementation)
  Future<bool> isConnectionMetered() async {
    // This would require platform-specific implementation
    // For now, assume WiFi is not metered, mobile data is metered
    return false; // Placeholder
  }

  /// Get connection type (placeholder - would need platform-specific
  /// implementation)
  Future<ConnectionType> getConnectionType() async {
    // This would require platform-specific implementation
    // For now, return unknown
    return ConnectionType.unknown; // Placeholder
  }
}

/// Connectivity status enumeration
enum ConnectivityStatus { unknown, connected, disconnected }

/// Connectivity quality levels
enum ConnectivityQuality { none, poor, fair, good, excellent }

/// Connection type enumeration
enum ConnectionType { unknown, wifi, mobile, ethernet }

/// Extension for connectivity status display
extension ConnectivityStatusExtension on ConnectivityStatus {
  String get displayName {
    switch (this) {
      case ConnectivityStatus.unknown:
        return 'Unknown';
      case ConnectivityStatus.connected:
        return 'Online';
      case ConnectivityStatus.disconnected:
        return 'Offline';
    }
  }

  String get icon {
    switch (this) {
      case ConnectivityStatus.unknown:
        return '❓';
      case ConnectivityStatus.connected:
        return '🌐';
      case ConnectivityStatus.disconnected:
        return '📵';
    }
  }
}

/// Extension for connectivity quality display
extension ConnectivityQualityExtension on ConnectivityQuality {
  String get displayName {
    switch (this) {
      case ConnectivityQuality.none:
        return 'No Connection';
      case ConnectivityQuality.poor:
        return 'Poor';
      case ConnectivityQuality.fair:
        return 'Fair';
      case ConnectivityQuality.good:
        return 'Good';
      case ConnectivityQuality.excellent:
        return 'Excellent';
    }
  }

  String get icon {
    switch (this) {
      case ConnectivityQuality.none:
        return '📵';
      case ConnectivityQuality.poor:
        return '📶';
      case ConnectivityQuality.fair:
        return '📶';
      case ConnectivityQuality.good:
        return '📶';
      case ConnectivityQuality.excellent:
        return '📶';
    }
  }
}

/// Extension for connection type display
extension ConnectionTypeExtension on ConnectionType {
  String get displayName {
    switch (this) {
      case ConnectionType.unknown:
        return 'Unknown';
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
    }
  }

  String get icon {
    switch (this) {
      case ConnectionType.unknown:
        return '❓';
      case ConnectionType.wifi:
        return '📶';
      case ConnectionType.mobile:
        return '📱';
      case ConnectionType.ethernet:
        return '🔌';
    }
  }
}
