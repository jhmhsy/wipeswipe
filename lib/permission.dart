import 'package:photo_manager/photo_manager.dart';

class GalleryRepository {
  //Create a repository for fetching photos
  Future<List<AssetEntity>> fetchPhotos({int limit = 200}) async {
    final permission = await checkPermission();

    if (permission != PermissionState.authorized) {
      throw GalleryPermissionException();
    }
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      hasAll: true,
      type: RequestType.image,
    );
    if (paths.isEmpty) return [];

    final AssetPathEntity all = paths.first;
    final List<AssetEntity> assets = await all.getAssetListPaged(
      page: 0,
      size: limit,
    );
    return assets;
  }

  static Future<PermissionState> checkPermission() async {
    final ps = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    print(ps);
    return ps;
  }

  static Future<bool> requestPermission() async {
    final currentState = await checkPermission();
    if (currentState == PermissionState.authorized) {
      return true;
    }

    final newState = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    print(newState);
    return newState == PermissionState.authorized;
  }
}

class GalleryPermissionException implements Exception {
  const GalleryPermissionException();
}
