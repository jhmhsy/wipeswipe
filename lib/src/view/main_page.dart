import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wipeswipe/bloc/photo_bloc.dart';
import 'package:wipeswipe/permission.dart';
import 'package:wipeswipe/src/view/review_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PhotoBloc>(
      create: (_) => PhotoBloc(GalleryRepository())..add(PhotosRequested()),
      child: MaterialApp(home: MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<PhotoBloc, PhotoState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(
            width: double.infinity,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 20,
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                FloatingActionButton(
                  shape: CircleBorder(),
                  heroTag: null,
                  child: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReviewPage(photoBloc: context.read<PhotoBloc>()),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 20,
                  child: Text(
                    "Keep",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Builder(
              builder: (context) {
                switch (state.status) {
                  case PhotoStatus.initial:
                  case PhotoStatus.loading:
                    return Center();
                  case PhotoStatus.permissionDenied:
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Permission needed to use the app.'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              PhotoManager.openSetting();
                            },
                            child: Text('Grant Permission'),
                          ),
                        ],
                      ),
                    );
                  case PhotoStatus.failure:
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('An error has occured: ${state.error}.'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<PhotoBloc>().add(
                              const PhotosRequested(),
                            ),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  case PhotoStatus.ready:
                    if (state.isDone) {
                      return _SummaryView(
                        assets: state.photos,
                        discarded: state.discarded,
                        onRestart: () => context.read<PhotoBloc>().add(
                          const SessionRestart(),
                        ),
                      );
                    }
                    final asset = state.current!;
                    return Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Dismissible(
                              key: ValueKey(asset.id),
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) {
                                final bloc = context.read<PhotoBloc>();
                                if (direction == DismissDirection.startToEnd) {
                                  bloc.add(const SwipeRight());
                                } else {
                                  bloc.add(const SwipeLeft());
                                }
                              },
                              background: _SwipeBackground(
                                color: Colors.green,
                                icon: Icons.check,
                              ),
                              secondaryBackground: _SwipeBackground(
                                color: Colors.red,
                                icon: Icons.close,
                                alignEnd: true,
                              ),
                              child: FutureBuilder<Uint8List?>(
                                future: asset.thumbnailDataWithSize(
                                  const ThumbnailSize(1200, 1200),
                                ),
                                builder: (context, snap) {
                                  if (!snap.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      16,
                                    ),
                                    child: Image.memory(
                                      snap.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    this.alignEnd = false,
  });
  final Color color;
  final IconData icon;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: color.withAlpha(1),
      child: Icon(icon, color: color, size: 48),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.assets,
    required this.discarded,
    required this.onRestart,
  });
  final List<AssetEntity> assets;
  final List<AssetEntity> discarded;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Done!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Kept: ${assets.length - discarded.length}, Discarded: ${discarded.length}',
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRestart, child: const Text('Restart')),
        ],
      ),
    );
  }
}
