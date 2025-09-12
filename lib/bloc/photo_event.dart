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

class UndoKept extends PhotoEvent {
  final List<AssetEntity> assets;
  const UndoKept(this.assets);
}

class UndoDiscarded extends PhotoEvent {
  final List<AssetEntity> assets;
  const UndoDiscarded(this.assets);
}
