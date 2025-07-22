import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/pack.dart';

enum DownloadedPacksPageStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for the home screen
class DownloadedPacksState extends Equatable {
  const DownloadedPacksState({
    this.status = DownloadedPacksPageStatus.initial,
    this.downloadedPacks = const [],
  });

  final DownloadedPacksPageStatus status;

  /// All packs
  final List<Pack> downloadedPacks;

  /// Creates a copy of this state with updated properties
  DownloadedPacksState copyWith({
    DownloadedPacksPageStatus? status,
    List<Pack>? downloadedPacks,
  }) {
    return DownloadedPacksState(
      status: status ?? this.status,
      downloadedPacks: downloadedPacks ?? this.downloadedPacks,
    );
  }

  @override
  List<Object?> get props => [
    status,
    downloadedPacks,
  ];
}
