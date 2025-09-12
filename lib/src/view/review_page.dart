import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ReviewPage extends StatefulWidget {
  final List<AssetEntity> assets;
  final Function(List<AssetEntity>) onUndo;
  final String title;
  const ReviewPage({
    super.key,
    required this.assets,
    required this.onUndo,
    required this.title,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final Set<AssetEntity> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          tooltip: "Back",
        ),
        title: Text("${widget.title} items:"),
      ),
      body: GridView.builder(
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
                    child: Image.memory(snapshot.data!, fit: BoxFit.cover),
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
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selected.isNotEmpty
            ? () => widget.onUndo(selected.toList())
            : null,
        child: const Icon(Icons.undo),
        tooltip: "Undo Selected",
      ),
    );
  }
}
