part of 'photo_bloc.dart';

enum PhotoStatus { initial, loading, ready, permissionDenied, failure }

class PhotoState extends Equatable {
  final PhotoStatus status;
  final int index;
  final List<AssetEntity> photos;
  final List<AssetEntity> kept;
  final List<AssetEntity> discarded;
  final String? error;

  const PhotoState({
    required this.status,
    required this.photos,
    required this.index,
    required this.kept,
    required this.discarded,
    this.error,
  });

  const PhotoState.initial()
    : status = PhotoStatus.initial,
      index = 0,
      photos = const [],
      kept = const [],
      discarded = const [],
      error = null;

  bool get hasCurrent => index >= 0 && index < photos.length;
  AssetEntity? get current => hasCurrent ? photos[index] : null;
  bool get isDone => index >= photos.length;

  PhotoState copyWith({
    Set<AssetEntity>? selected,
    PhotoStatus? status,
    List<AssetEntity>? photos,
    int? index,
    List<AssetEntity>? kept,
    List<AssetEntity>? discarded,
    String? error,
  }) {
    return PhotoState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      index: index ?? this.index,
      kept: kept ?? this.kept,
      discarded: discarded ?? this.discarded,
    );
  }

  @override
  List<Object?> get props => [status, photos, index, kept, discarded, error];
}
