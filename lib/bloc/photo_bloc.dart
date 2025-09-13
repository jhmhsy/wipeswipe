
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
    on<DeletePhotos>(_onDeletePhotos);
    on<PhotoToggleSelection>(_onPhotoToggleSelection);
    on<ClearAll>(_onClearAll);
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
        kept: List.of(state.kept)..remove(current),
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
        discarded: List.of(state.discarded)..remove(current),
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

  void _onPhotoToggleSelection(
    PhotoToggleSelection event,
    Emitter<PhotoState> emit,
  ) {
    final asset = event.asset;
    final shouldBeDeleted = event.shouldBeDeleted;

    final newDiscarded = shouldBeDeleted
        ? _addIfNotPresent(state.discarded, asset)
        : _removebyId(state.discarded, asset.id);

    final newKept = shouldBeDeleted
        ? _removebyId(state.kept, asset.id)
        : _addIfNotPresent(state.kept, asset);

    emit(state.copyWith(discarded: newDiscarded, kept: newKept));
  }

  void _onDeletePhotos(DeletePhotos event, Emitter<PhotoState> emit) async {
    if (state.discarded.isEmpty) {
      return;
    }
    try {
      emit(state.copyWith(status: PhotoStatus.loading));
      final success = await _repo.deletePhotos(state.discarded);
      if (success) {
        final photos = await _repo.fetchPhotos(limit: 200);
        emit(
          state.copyWith(
            status: PhotoStatus.ready,
            photos: photos,
            index: 0,
            kept: const [],
            discarded: const [],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PhotoStatus.failure,
            error: 'Failed to delete photos',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PhotoStatus.failure,
          error: 'Error deleting photos: $e',
        ),
      );
    }
  }

  void _onClearAll(ClearAll event, Emitter<PhotoState> emit) {
    final newKept = [...state.kept, ...state.discarded];
    emit(state.copyWith(kept: newKept, discarded: []));
  }

  List<AssetEntity> _removebyId(List<AssetEntity> list, String id) {
    return list.where((item) => item.id != id).toList();
  }

  List<AssetEntity> _addIfNotPresent(
    List<AssetEntity> list,
    AssetEntity asset,
  ) {
    if (list.any((item) => item.id == asset.id)) return list;
    return [...list, asset];
  }
}
