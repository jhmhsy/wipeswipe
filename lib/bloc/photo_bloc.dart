import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wipeswipe/permission.dart';
part 'photo_event.dart';
part 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc(this._repo) : super(const PhotoState.initial()) {
    on<PhotosRequested>(_onPhotosRequested);
    on<SwipeLeft>(_onSwipeLeft);
    on<SwipeRight>(_onSwipeRight);
    on<SessionRestart>(_onRestartSession);
  }
  final GalleryRepository _repo;
  //add stuff for clout
  Future<void> _onPhotosRequested(
    PhotosRequested event,
    Emitter<PhotoState> emit,
  ) async {
    emit(state.copyWith(status: PhotoStatus.loading));
    try {
      final photos = await _repo.fetchPhotos(limit: event.limit ?? 200);
      emit(
        state.copyWith(
          status: PhotoStatus.ready,
          photos: photos,
          index: 0,
          kept: const [],
          discarded: const [],
        ),
      );
    } on GalleryPermissionException {
      emit(state.copyWith(status: PhotoStatus.permissionDenied));
    } catch (e) {
      emit(state.copyWith(status: PhotoStatus.failure, error: e.toString()));
    }
  }

  void _onSwipeLeft(SwipeLeft event, Emitter<PhotoState> emit) {
    if (!state.hasCurrent) return;
    final current = state.current!;
    emit(
      state.copyWith(
        discarded: List.of(state.discarded)..add(current),
        index: state.index + 1,
      ),
    );
  }

  void _onSwipeRight(SwipeRight event, Emitter<PhotoState> emit) {
    if (!state.hasCurrent) return;
    final current = state.current!;

    emit(
      state.copyWith(
        kept: List.of(state.kept)..add(current),
        index: state.index + 1,
      ),
    );
  }

  void _onRestartSession(SessionRestart event, Emitter<PhotoState> emit) {
    emit(
      state.copyWith(
        index: 0,
        kept: const [],
        discarded: const [],
        status: state.photos.isEmpty ? PhotoStatus.initial : PhotoStatus.ready,
      ),
    );
  }
}
