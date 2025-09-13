part of 'photo_bloc.dart';

class PhotoEvent extends Equatable {
  const PhotoEvent();
  @override
  List<Object?> get props => [];
}

class PhotosRequested extends PhotoEvent {
  const PhotosRequested({this.limit});
  final int? limit;
}

class SwipeLeft extends PhotoEvent {
  const SwipeLeft();
}

class SwipeRight extends PhotoEvent {
  const SwipeRight();
}

class SessionRestart extends PhotoEvent {
  const SessionRestart();
}

class DeletePhotos extends PhotoEvent {
  const DeletePhotos();
}

class PhotoToggleSelection extends PhotoEvent {
  final AssetEntity asset;
  final bool shouldBeDeleted;

  const PhotoToggleSelection(this.asset, this.shouldBeDeleted);

  @override
  List<Object?> get props => [asset, shouldBeDeleted];
}

class ClearAll extends PhotoEvent {
  const ClearAll();
}
