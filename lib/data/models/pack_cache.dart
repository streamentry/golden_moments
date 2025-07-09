import 'package:equatable/equatable.dart';
import 'package:memory_lane/game/models/models.dart';

/// Cached pack data with local file paths and metadata
class PackCache extends Equatable {
  const PackCache({
    required this.id,
    required this.version,
    required this.downloadedAt,
    required this.expiresAt,
    required this.manifest,
    required this.images,
  });

  final String id;
  final String version;
  final DateTime downloadedAt;
  final DateTime expiresAt;
  final GamePack manifest;
  final List<CachedImage> images;

  factory PackCache.fromJson(Map<String, dynamic> json) {
    return PackCache(
      id: json['id'] as String,
      version: json['version'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      manifest: GamePack.fromJson(json['manifest'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((item) => CachedImage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'downloadedAt': downloadedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'manifest': manifest.toJson(),
      'images': images.map((image) => image.toJson()).toList(),
    };
  }

  PackCache copyWith({
    String? id,
    String? version,
    DateTime? downloadedAt,
    DateTime? expiresAt,
    GamePack? manifest,
    List<CachedImage>? images,
  }) {
    return PackCache(
      id: id ?? this.id,
      version: version ?? this.version,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      manifest: manifest ?? this.manifest,
      images: images ?? this.images,
    );
  }

  /// Create a new pack cache with 60-day expiry
  factory PackCache.create({
    required String id,
    required String version,
    required GamePack manifest,
    List<CachedImage>? images,
  }) {
    final now = DateTime.now();
    return PackCache(
      id: id,
      version: version,
      downloadedAt: now,
      expiresAt: now.add(const Duration(days: 60)),
      manifest: manifest,
      images: images ?? [],
    );
  }

  /// Add or update a cached image
  PackCache addImage(CachedImage image) {
    final updatedImages = List<CachedImage>.from(images);
    final existingIndex = updatedImages.indexWhere((img) => img.id == image.id);
    
    if (existingIndex >= 0) {
      updatedImages[existingIndex] = image;
    } else {
      updatedImages.add(image);
    }
    
    return copyWith(images: updatedImages);
  }

  /// Remove a cached image
  PackCache removeImage(String imageId) {
    final updatedImages = images.where((img) => img.id != imageId).toList();
    return copyWith(images: updatedImages);
  }

  /// Get downloaded images count
  int get downloadedImagesCount => 
      images.where((img) => img.status == ImageCacheStatus.downloaded).length;

  /// Get total cache size in bytes
  int get totalSize => images.fold(0, (sum, img) => sum + img.size);

  /// Check if pack is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if all images are downloaded
  bool get isComplete => downloadedImagesCount >= manifest.tiles.length;

  /// Get download progress (0.0 to 1.0)
  double get downloadProgress {
    if (manifest.tiles.isEmpty) return 1.0;
    return downloadedImagesCount / manifest.tiles.length;
  }

  /// Get cached image by ID
  CachedImage? getImage(String imageId) {
    try {
      return images.firstWhere((img) => img.id == imageId);
    } catch (e) {
      return null;
    }
  }

  /// Get all downloaded images
  List<CachedImage> get downloadedImages => 
      images.where((img) => img.status == ImageCacheStatus.downloaded).toList();

  @override
  List<Object?> get props => [
        id,
        version,
        downloadedAt,
        expiresAt,
        manifest,
        images,
      ];
}

/// Cached image with local file path and metadata
class CachedImage extends Equatable {
  const CachedImage({
    required this.id,
    required this.filename,
    required this.caption,
    required this.altText,
    required this.localPath,
    required this.thumbnailPath,
    required this.downloadUrl,
    required this.size,
    required this.dimensions,
    required this.format,
    required this.checksum,
    required this.downloadedAt,
    required this.status,
  });

  final String id;
  final String filename;
  final String caption;
  final String altText;
  final String localPath;
  final String? thumbnailPath;
  final String downloadUrl;
  final int size;
  final String dimensions;
  final String format;
  final String checksum;
  final DateTime downloadedAt;
  final ImageCacheStatus status;

  factory CachedImage.fromJson(Map<String, dynamic> json) {
    return CachedImage(
      id: json['id'] as String,
      filename: json['filename'] as String,
      caption: json['caption'] as String,
      altText: json['altText'] as String? ?? '',
      localPath: json['localPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      downloadUrl: json['downloadUrl'] as String,
      size: json['size'] as int,
      dimensions: json['dimensions'] as String,
      format: json['format'] as String,
      checksum: json['checksum'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      status: ImageCacheStatus.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'caption': caption,
      'altText': altText,
      'localPath': localPath,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'downloadUrl': downloadUrl,
      'size': size,
      'dimensions': dimensions,
      'format': format,
      'checksum': checksum,
      'downloadedAt': downloadedAt.toIso8601String(),
      'status': status.toString(),
    };
  }

  CachedImage copyWith({
    String? id,
    String? filename,
    String? caption,
    String? altText,
    String? localPath,
    String? thumbnailPath,
    String? downloadUrl,
    int? size,
    String? dimensions,
    String? format,
    String? checksum,
    DateTime? downloadedAt,
    ImageCacheStatus? status,
  }) {
    return CachedImage(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      caption: caption ?? this.caption,
      altText: altText ?? this.altText,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      size: size ?? this.size,
      dimensions: dimensions ?? this.dimensions,
      format: format ?? this.format,
      checksum: checksum ?? this.checksum,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      status: status ?? this.status,
    );
  }

  /// Create a new cached image entry
  factory CachedImage.create({
    required String id,
    required String filename,
    required String caption,
    required String altText,
    required String localPath,
    String? thumbnailPath,
    required String downloadUrl,
    required int size,
    required String dimensions,
    required String format,
    required String checksum,
  }) {
    return CachedImage(
      id: id,
      filename: filename,
      caption: caption,
      altText: altText,
      localPath: localPath,
      thumbnailPath: thumbnailPath,
      downloadUrl: downloadUrl,
      size: size,
      dimensions: dimensions,
      format: format,
      checksum: checksum,
      downloadedAt: DateTime.now(),
      status: ImageCacheStatus.downloaded,
    );
  }

  /// Check if image file exists locally
  bool get isAvailable => status == ImageCacheStatus.downloaded;

  /// Get file size in MB
  double get sizeInMB => size / (1024 * 1024);

  @override
  List<Object?> get props => [
        id,
        filename,
        caption,
        altText,
        localPath,
        thumbnailPath,
        downloadUrl,
        size,
        dimensions,
        format,
        checksum,
        downloadedAt,
        status,
      ];
}

/// Image cache status enumeration
enum ImageCacheStatus {
  pending,
  downloading,
  downloaded,
  failed,
  expired;

  static ImageCacheStatus fromString(String value) {
    return ImageCacheStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ImageCacheStatus.pending,
    );
  }

  @override
  String toString() => name;
}
