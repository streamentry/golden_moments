import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/image.dart';

/// Represents a single tile in the memory matching game
class GameTile extends Equatable {
  const GameTile({
    required this.id,
    required this.image,
    this.isMatched = false,
    this.isRevealed = false,
    this.pairId,
  });

  /// Creates a GameTile from JSON data
  factory GameTile.fromJson(Map<String, dynamic> json) {
    return GameTile(
      id: json['id'] as String,
      image: Image.fromJson(json['image'] as Map<String, dynamic>),
      isMatched: json['isMatched'] as bool? ?? false,
      isRevealed: json['isRevealed'] as bool? ?? false,
      pairId: json['pairId'] as String?,
    );
  }

  final String id;

  /// Image
  final Image image;

  /// Whether this tile has been successfully matched
  final bool isMatched;

  /// Whether this tile is currently face-up/revealed
  final bool isRevealed;

  /// ID that links this tile to its matching pair
  final String? pairId;

  /// Converts this GameTile to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'isMatched': isMatched,
      'isRevealed': isRevealed,
      if (pairId != null) 'pairId': pairId,
    };
  }

  /// Creates a copy of this tile with updated properties
  GameTile copyWith({
    String? id,
    Image? image,
    bool? isMatched,
    bool? isRevealed,
    String? pairId,
  }) {
    return GameTile(
      id: id ?? this.id,
      image: image ?? this.image,
      isMatched: isMatched ?? this.isMatched,
      isRevealed: isRevealed ?? this.isRevealed,
      pairId: pairId ?? this.pairId,
    );
  }

  @override
  List<Object?> get props => [id, image, isMatched, isRevealed, pairId];
}
