import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/pack.dart';

/// Manages pack download status and provides status change notifications
class PackStatusManager extends ChangeNotifier {
  new();

  final Map<String, PackStatus> _packsStatus = {};
  final _statusController =
      StreamController<MapEntry<String, PackStatus>>.broadcast();

  /// Stream of pack status changes
  Stream<MapEntry<String, PackStatus>> get onStatusChanged =>
      _statusController.stream;

  /// Get status of a specific pack
  PackStatus getPackStatus(String packId) {
    return _packsStatus[packId] ?? PackStatus.notStarted;
  }

  /// Get status of all packs
  Map<String, PackStatus> getPacksStatus() {
    return Map.unmodifiable(_packsStatus);
  }

  /// Check if a pack is downloaded
  bool isDownloaded(String packId) =>
      getPackStatus(packId) == PackStatus.completed;

  /// Update pack status and notify listeners
  void updatePackStatus(String packId, PackStatus status) {
    if (_packsStatus[packId] != status) {
      _packsStatus[packId] = status;
      _statusController.add(MapEntry(packId, status));
      notifyListeners();
    }
  }

  /// Initialize pack status from cache
  void initializePackStatus(String packId, PackStatus status) {
    _packsStatus[packId] = status;
  }

  /// Set multiple pack statuses at once (for initialization)
  void initializePackStatuses(Map<String, PackStatus> statuses) {
    _packsStatus.addAll(statuses);
  }

  /// Reset pack status to not started
  void resetPackStatus(String packId) {
    updatePackStatus(packId, PackStatus.notStarted);
  }

  /// Mark pack as downloading
  void markAsDownloading(String packId) {
    updatePackStatus(packId, PackStatus.downloading);
  }

  /// Mark pack as completed
  void markAsCompleted(String packId) {
    updatePackStatus(packId, PackStatus.completed);
  }

  /// Mark pack as failed
  void markAsFailed(String packId) {
    updatePackStatus(packId, PackStatus.notStarted);
  }

  /// Get count of packs by status
  int getPackCountByStatus(PackStatus status) {
    return _packsStatus.values.where((s) => s == status).length;
  }

  /// Get all pack IDs with a specific status
  List<String> getPackIdsByStatus(PackStatus status) {
    return _packsStatus.entries
        .where((entry) => entry.value == status)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  void dispose() {
    unawaited(_statusController.close());
    super.dispose();
  }
}
