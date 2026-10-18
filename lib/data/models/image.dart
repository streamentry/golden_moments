import 'package:equatable/equatable.dart';

class Image extends Equatable {
  const new({required this.id, required this.url, required this.caption});

  /// Creates a Image from JSON data
  factory fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String,
    );
  }

  /// Unique identifier
  final String id;

  /// Image url
  final String url;

  /// Image caption
  final String caption;

  /// Converts this Image to JSON data
  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'caption': caption};
  }

  /// Creates a copy of this image with updated properties
  Image copyWith({String? id, String? url, String? caption}) {
    return Image(
      id: id ?? this.id,
      url: url ?? this.url,
      caption: caption ?? this.caption,
    );
  }

  @override
  List<Object?> get props => [id, url, caption];
}
