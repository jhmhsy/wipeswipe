import 'package:photo_manager/photo_manager.dart';

class GalleryRepository {
  //Create a repository for fetching photos
  Future<List<AssetEntity>> fetchPhotos({int limit = 200}) async {
    final permission = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );

    if (permission != PermissionState.authorized) throw GalleryPermissionException();
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

  static Future<bool> requestPermission() async {
    final ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    if (ps == PermissionState.denied) {
      return false;
    }
    return ps.isAuth;
  }
}

class GalleryPermissionException implements Exception {
  const GalleryPermissionException();
}
