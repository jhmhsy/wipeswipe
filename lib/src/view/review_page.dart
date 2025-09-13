import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wipeswipe/bloc/photo_bloc.dart';

class ReviewPage extends StatefulWidget {
  final PhotoBloc photoBloc;
  const ReviewPage({super.key, required this.photoBloc});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool isDeleting = false;
  final Map<String, Uint8List?> _thumbnailCache = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoBloc, PhotoState>(
      bloc: widget.photoBloc,
      listener: (context, state) {
        if (isDeleting) {
          if (state.status == PhotoStatus.failure) {
            setState(() => isDeleting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == PhotoStatus.ready) {
            setState(() => isDeleting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photos deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            tooltip: "Back",
          ),
          title: const Text("Review items:"),
          actions: [
            if (context.read<PhotoBloc>().state.discarded.isNotEmpty)
              TextButton(
                onPressed: () {
                  context.read<PhotoBloc>().add(ClearAll());
                },
                child: const Text('Clear All'),
              ),
          ],
        ),
        body: BlocBuilder<PhotoBloc, PhotoState>(
          builder: (context, state) {
            if (state.status == PhotoStatus.loading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading photos...'),
                  ],
                ),
              );
            }
            final totalPhotos = state.photos.length;
            final rowCount = (totalPhotos + 3) ~/ 4; 
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: rowCount,
              itemBuilder: (context, rowIndex) {
                return _buildImageRow(state.photos, rowIndex * 4);
              },
            );
          },
        ),
        floatingActionButton:
            (context.read<PhotoBloc>().state.discarded.isNotEmpty &&
                !isDeleting)
            ? FloatingActionButton.extended(
                onPressed: () {
                  setState(() => isDeleting = true);
                  context.read<PhotoBloc>().add(DeletePhotos());
                },
                backgroundColor: Colors.red,
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  'Delete ${context.read<PhotoBloc>().state.discarded.length}',
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildImageRow(List<AssetEntity> photos, int startIndex) {
    final rows = <Widget>[];
    final end = min(startIndex + 4, photos.length);

    for (int i = startIndex; i < end; i++) {
      final asset = photos[i];

      rows.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FutureBuilder<Uint8List?>(
              future: _loadCachedThumbnail(asset),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Checkbox(
                        value: context
                            .read<PhotoBloc>()
                            .state
                            .discarded
                            .contains(asset),
                        onChanged: (checked) {
                          context.read<PhotoBloc>().add(
                            PhotoToggleSelection(asset, checked ?? false),
                          );
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    if (context.read<PhotoBloc>().state.discarded.contains(
                      asset,
                    ))
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
  //Helper, to avoid re-rendering of all images, cache each image
  Future<Uint8List?> _loadCachedThumbnail(AssetEntity asset) async {
    if (_thumbnailCache.containsKey(asset.id)) {
      return _thumbnailCache[asset.id];
    }

    final data = await asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
    );
    _thumbnailCache[asset.id] = data;
    return data;
  }
}
