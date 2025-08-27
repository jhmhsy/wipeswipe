import 'package:photo_manager/photo_manager.dart';

class GalleryRepository {
  //Create a repository for fetching photos
  Future<List<AssetEntity>> fetchPhotos({int limit = 200}) async {
    PermissionState ps = await PhotoManager.requestPermissionExtend();
    //ask permission
    if (!ps.isAuth) {
      PhotoManager.openSetting();
      throw const GalleryPermissionException();
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
}

class GalleryPermissionException implements Exception {
  const GalleryPermissionException();
}
