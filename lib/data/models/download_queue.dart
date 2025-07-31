import 'package:equatable/equatable.dart';

/// Download queue management for packs and images
class DownloadQueue extends Equatable {
  const DownloadQueue({
    required this.activeDownloads,
    required this.queuedDownloads,
    required this.completedDownloads,
    required this.failedDownloads,
  });

  factory DownloadQueue.fromJson(Map<String, dynamic> json) {
    return DownloadQueue(
      activeDownloads: (json['activeDownloads'] as List<dynamic>? ?? [])
          .map((item) => DownloadItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      queuedDownloads: (json['queuedDownloads'] as List<dynamic>? ?? [])
          .map((item) => DownloadItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      completedDownloads: (json['completedDownloads'] as List<dynamic>? ?? [])
          .map((item) => DownloadItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      failedDownloads: (json['failedDownloads'] as List<dynamic>? ?? [])
          .map((item) => DownloadItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DownloadQueue.empty() {
    return const DownloadQueue(
      activeDownloads: [],
      queuedDownloads: [],
      completedDownloads: [],
      failedDownloads: [],
    );
  }

  final List<DownloadItem> activeDownloads;
  final List<DownloadItem> queuedDownloads;
  final List<DownloadItem> completedDownloads;
  final List<DownloadItem> failedDownloads;

  Map<String, dynamic> toJson() {
    return {
      'activeDownloads': activeDownloads.map((item) => item.toJson()).toList(),
      'queuedDownloads': queuedDownloads.map((item) => item.toJson()).toList(),
      'completedDownloads': completedDownloads
          .map((item) => item.toJson())
          .toList(),
      'failedDownloads': failedDownloads.map((item) => item.toJson()).toList(),
    };
  }

  DownloadQueue copyWith({
    List<DownloadItem>? activeDownloads,
    List<DownloadItem>? queuedDownloads,
    List<DownloadItem>? completedDownloads,
    List<DownloadItem>? failedDownloads,
  }) {
    return DownloadQueue(
      activeDownloads: activeDownloads ?? this.activeDownloads,
      queuedDownloads: queuedDownloads ?? this.queuedDownloads,
      completedDownloads: completedDownloads ?? this.completedDownloads,
      failedDownloads: failedDownloads ?? this.failedDownloads,
    );
  }

  /// Add a new download to the queue
  DownloadQueue addDownload(DownloadItem item) {
    final updatedQueue = List<DownloadItem>.from(queuedDownloads)
      ..add(item)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return copyWith(queuedDownloads: updatedQueue);
  }

  /// Move download from queued to active
  DownloadQueue startDownload(String downloadId) {
    final item = queuedDownloads.firstWhere((item) => item.id == downloadId);
    final updatedQueued = queuedDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedActive = [
      ...activeDownloads,
      item.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      ),
    ];

    return copyWith(
      queuedDownloads: updatedQueued,
      activeDownloads: updatedActive,
    );
  }

  /// Complete a download
  DownloadQueue completeDownload(String downloadId, {Duration? downloadTime}) {
    final item = activeDownloads.firstWhere((item) => item.id == downloadId);
    final updatedActive = activeDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedCompleted = [
      ...completedDownloads,
      item.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
        downloadTime: downloadTime,
      ),
    ];

    return copyWith(
      activeDownloads: updatedActive,
      completedDownloads: updatedCompleted,
    );
  }

  /// Fail a download
  DownloadQueue failDownload(String downloadId, String errorMessage) {
    final item = activeDownloads.firstWhere((item) => item.id == downloadId);
    final updatedActive = activeDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedFailed = [
      ...failedDownloads,
      item.copyWith(
        status: DownloadStatus.failed,
        errorMessage: errorMessage,
        retryCount: item.retryCount + 1,
      ),
    ];

    return copyWith(
      activeDownloads: updatedActive,
      failedDownloads: updatedFailed,
    );
  }

  /// Pause a download (move from active to queued)
  DownloadQueue pauseDownload(String downloadId) {
    final item = activeDownloads.firstWhere((item) => item.id == downloadId);
    final updatedActive = activeDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedQueued = [
      ...queuedDownloads,
      item.copyWith(
        status: DownloadStatus.queued,
      ),
    ];

    return copyWith(
      activeDownloads: updatedActive,
      queuedDownloads: updatedQueued,
    );
  }

  /// Resume a paused download (move from queued to active)
  DownloadQueue resumeDownload(String downloadId) {
    final item = queuedDownloads.firstWhere((item) => item.id == downloadId);
    final updatedQueued = queuedDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedActive = [
      ...activeDownloads,
      item.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      ),
    ];

    return copyWith(
      queuedDownloads: updatedQueued,
      activeDownloads: updatedActive,
    );
  }

  /// Cancel a download (remove from any list)
  DownloadQueue cancelDownload(String downloadId) {
    final updatedActive = activeDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedQueued = queuedDownloads
        .where((item) => item.id != downloadId)
        .toList();

    return copyWith(
      activeDownloads: updatedActive,
      queuedDownloads: updatedQueued,
    );
  }

  /// Retry a failed download (move from failed to queued)
  DownloadQueue retryDownload(String downloadId) {
    final item = failedDownloads.firstWhere((item) => item.id == downloadId);
    final updatedFailed = failedDownloads
        .where((item) => item.id != downloadId)
        .toList();
    final updatedQueued = [
      ...queuedDownloads,
      item.copyWith(
        status: DownloadStatus.queued,
      ),
    ];

    return copyWith(
      failedDownloads: updatedFailed,
      queuedDownloads: updatedQueued,
    );
  }

  /// Get download item by ID from any list
  DownloadItem? getDownload(String downloadId) {
    for (final item in [
      ...activeDownloads,
      ...queuedDownloads,
      ...completedDownloads,
      ...failedDownloads,
    ]) {
      if (item.id == downloadId) {
        return item;
      }
    }
    return null;
  }

  /// Check if download exists in any state
  bool hasDownload(String downloadId) {
    return getDownload(downloadId) != null;
  }

  /// Update download progress
  DownloadQueue updateProgress(String downloadId, double progress) {
    final updatedActive = activeDownloads.map((item) {
      if (item.id == downloadId) {
        return item.copyWith(progress: progress);
      }
      return item;
    }).toList();

    return copyWith(activeDownloads: updatedActive);
  }

  /// Get total downloads count
  int get totalDownloads =>
      activeDownloads.length +
      queuedDownloads.length +
      completedDownloads.length +
      failedDownloads.length;

  @override
  List<Object?> get props => [
    activeDownloads,
    queuedDownloads,
    completedDownloads,
    failedDownloads,
  ];
}

/// Individual download item
class DownloadItem extends Equatable {
  const DownloadItem({
    required this.id,
    required this.packId,
    required this.type,
    required this.status,
    required this.priority,
    required this.retryCount,
    required this.queuedAt,
    required this.imageId,
    required this.imageUrl,
    this.startedAt,
    this.completedAt,
    this.progress = 0.0,
    this.downloadTime,
    this.errorMessage,
    this.totalImages,
  });

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] as String,
      packId: json['packId'] as String,
      imageId: json['imageId'] as String,
      imageUrl: json['imageUrl'] as String,
      type: DownloadType.fromString(json['type'] as String),
      status: DownloadStatus.fromString(json['status'] as String),
      priority: json['priority'] as int? ?? 0,
      retryCount: json['retryCount'] as int? ?? 0,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      downloadTime: json['downloadTime'] != null
          ? Duration(seconds: json['downloadTime'] as int)
          : null,
      errorMessage: json['errorMessage'] as String?,
      totalImages: json['totalImages'] as int?,
    );
  }

  final String id;
  final String packId;
  final String imageId;
  final String imageUrl;
  final DownloadType type;
  final DownloadStatus status;
  final int priority;
  final int retryCount;
  final DateTime queuedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progress;
  final Duration? downloadTime;
  final String? errorMessage;
  final int? totalImages;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packId': packId,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'type': type.toString(),
      'status': status.toString(),
      'priority': priority,
      'retryCount': retryCount,
      'queuedAt': queuedAt.toIso8601String(),
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'progress': progress,
      if (downloadTime != null) 'downloadTime': downloadTime!.inSeconds,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (totalImages != null) 'totalImages': totalImages,
    };
  }

  DownloadItem copyWith({
    String? id,
    String? packId,
    String? imageId,
    String? imageUrl,
    DownloadType? type,
    DownloadStatus? status,
    int? priority,
    int? retryCount,
    DateTime? queuedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
    Duration? downloadTime,
    String? errorMessage,
    int? totalImages,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      queuedAt: queuedAt ?? this.queuedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      downloadTime: downloadTime ?? this.downloadTime,
      errorMessage: errorMessage ?? this.errorMessage,
      totalImages: totalImages ?? this.totalImages,
    );
  }

  @override
  List<Object?> get props => [
    id,
    packId,
    imageId,
    imageUrl,
    type,
    status,
    priority,
    retryCount,
    queuedAt,
    startedAt,
    completedAt,
    progress,
    downloadTime,
    errorMessage,
    totalImages,
  ];
}

/// Download type enumeration
enum DownloadType {
  pack,
  image;

  static DownloadType fromString(String value) {
    return DownloadType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => DownloadType.pack,
    );
  }

  @override
  String toString() => name;
}

/// Download status enumeration
enum DownloadStatus {
  queued,
  downloading,
  completed,
  failed,
  cancelled;

  static DownloadStatus fromString(String value) {
    return DownloadStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DownloadStatus.queued,
    );
  }

  @override
  String toString() => name;
}
