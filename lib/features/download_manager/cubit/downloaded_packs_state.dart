import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/pack.dart';

enum DownloadedPacksPageStatus { initial, loading, loaded, error }

/// State for the home screen
class DownloadedPacksState extends Equatable {
  const DownloadedPacksState({
    this.status = DownloadedPacksPageStatus.initial,
    this.packs = const [],
    this.downloadedPacks = const [],
    this.notDownloadedPacks = const [],
  });

  final DownloadedPacksPageStatus status;

  /// All packs
  final List<Pack> packs;

  /// Downloaded packs
  final List<Pack> downloadedPacks;

  /// Not downloaded packs
  final List<Pack> notDownloadedPacks;

  /// Creates a copy of this state with updated properties
  DownloadedPacksState copyWith({
    DownloadedPacksPageStatus? status,
    List<Pack>? packs,
    List<Pack>? downloadedPacks,
    List<Pack>? notDownloadedPacks,
  }) {
    return DownloadedPacksState(
      status: status ?? this.status,
      packs: packs ?? this.packs,
      downloadedPacks: downloadedPacks ?? this.downloadedPacks,
      notDownloadedPacks: notDownloadedPacks ?? this.notDownloadedPacks,
    );
  }

  @override
  List<Object?> get props => [
    status,
    packs,
    downloadedPacks,
    notDownloadedPacks,
  ];
}
