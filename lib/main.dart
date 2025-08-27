import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wipeswipe/bloc/photo_bloc.dart';
import 'package:wipeswipe/observer.dart';
import 'package:wipeswipe/permission.dart';
import 'package:wipeswipe/src/view/main_page.dart';

void main() {
  Bloc.observer = GlobalObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(create: (_) => PhotoBloc(GalleryRepository())..add(PhotosRequested()), child: MainPage()),
    );
  }
}
