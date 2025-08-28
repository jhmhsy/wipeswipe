import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wipeswipe/bloc/photo_bloc.dart';
import 'package:wipeswipe/permission.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: BlocProvider(
        create: (_) => PhotoBloc(GalleryRepository())..add(PhotosRequested()),
        child: MainPage(),
      ),
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
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PhotoBloc, PhotoState>(
          builder: (context, state) {
            switch (state.status) {
              case PhotoStatus.initial:
              case PhotoStatus.loading:
                return Center(child: CircularProgressIndicator());
              case PhotoStatus.permissionDenied:
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Permission needed to use the app.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<PhotoBloc>().add(
                          const PhotosRequested(),
                        ),
                        child: Text('Try again'),
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
                    kept: state.kept.length,
                    discarded: state.discarded.length,
                    onRestart: () =>
                        context.read<PhotoBloc>().add(const SessionRestart()),
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
                                borderRadius: BorderRadiusGeometry.circular(16),
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
      alignment: alignEnd ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: color.withAlpha(1),
      child: Icon(icon, color: Colors.green, size: 48),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.kept,
    required this.discarded,
    required this.onRestart,
  });
  final int kept;
  final int discarded;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Done!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Kept: $kept, Discarded: $discarded'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRestart, child: const Text('Restart')),
        ],
      ),
    );
  }
}
