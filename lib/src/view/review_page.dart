import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wipeswipe/bloc/photo_bloc.dart';

class ReviewPage extends StatefulWidget {
  final List<AssetEntity> assets;
  final PhotoBloc photoBloc;
  const ReviewPage({super.key, required this.assets, required this.photoBloc});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Set<AssetEntity> selected = {};
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    selected = {};
  }

  Future<void> _deleteSelectedPhotos() async {
    if (selected.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${selected.length} photos?'),
        content: const Text('Delete Photos from device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.photoBloc.add(DeletePhotos(selected.toList()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleting ${selected.length} photos...'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoBloc, PhotoState>(
      bloc: widget.photoBloc,
      listener: (context, state) {
        if (isDeleting) {
          if (state.status == PhotoStatus.failure) {
            setState(() {
              isDeleting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == PhotoStatus.ready) {
            setState(() {
              isDeleting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photos deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Go back to main page
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            tooltip: "Back",
          ),
          title: Text("Review items:"),
          actions: [
            if (selected.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    selected.clear();
                  });
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
                    Text('Deleting photos...'),
                  ],
                ),
              );
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: widget.assets.length,
              itemBuilder: (context, index) {
                final asset = widget.assets[index];
                return FutureBuilder<Uint8List?>(
                  future:
                      asset.thumbnailDataWithSize(const ThumbnailSize(300, 300))
                          as Future<Uint8List?>?,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Checkbox(
                            value: selected.contains(asset),
                            onChanged: (checked) {
                              if (mounted) {
                                setState(() {
                                  if (checked == true) {
                                    selected.add(asset);
                                  } else {
                                    selected.remove(asset);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        if (selected.contains(asset))
                          Positioned(
                            child: const Center(
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: selected.isNotEmpty && !isDeleting
            ? FloatingActionButton.extended(
                onPressed: _deleteSelectedPhotos,
                backgroundColor: Colors.red,
                icon: const Icon(Icons.delete_forever),
                label: Text('Delete ${selected.length}'),
              )
            : null,
      ),
    );
  }
}
