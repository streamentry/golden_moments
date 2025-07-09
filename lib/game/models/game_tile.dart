import 'package:equatable/equatable.dart';

/// Represents a single tile in the memory matching game
class GameTile extends Equatable {
  const GameTile({
    required this.id,
    required this.imageUrl,
    required this.caption,
    this.isMatched = false,
    this.isRevealed = false,
    this.pairId,
  });

  /// Unique identifier for this tile
  final String id;

  /// URL or asset path for the tile image
  final String imageUrl;

  /// Caption/description shown when tile is matched
  final String caption;

  /// Whether this tile has been successfully matched
  final bool isMatched;

  /// Whether this tile is currently face-up/revealed
  final bool isRevealed;

  /// ID that links this tile to its matching pair
  final String? pairId;

  /// Creates a GameTile from JSON data
  factory GameTile.fromJson(Map<String, dynamic> json) {
    return GameTile(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String,
      isMatched: json['isMatched'] as bool? ?? false,
      isRevealed: json['isRevealed'] as bool? ?? false,
      pairId: json['pairId'] as String?,
    );
  }

  /// Converts this GameTile to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'caption': caption,
      'isMatched': isMatched,
      'isRevealed': isRevealed,
      if (pairId != null) 'pairId': pairId,
    };
  }

  /// Creates a copy of this tile with updated properties
  GameTile copyWith({
    String? id,
    String? imageUrl,
    String? caption,
    bool? isMatched,
    bool? isRevealed,
    String? pairId,
  }) {
    return GameTile(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      isMatched: isMatched ?? this.isMatched,
      isRevealed: isRevealed ?? this.isRevealed,
      pairId: pairId ?? this.pairId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        caption,
        isMatched,
        isRevealed,
        pairId,
      ];
}
