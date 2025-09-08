import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wipeswipe/observer.dart';
import 'package:wipeswipe/permission.dart';
import 'package:wipeswipe/src/view/main_page.dart';
import 'package:wipeswipe/src/view/welcome_page.dart';

void main() {
  Bloc.observer = GlobalObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<PermissionState>(
        future: GalleryRepository.checkPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black87,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.black87,
              body: Center(child: Text('An error has occured.')),
            );
          }
          final permissionState = snapshot.data;
          if (permissionState == PermissionState.authorized) {
            return MainScreen();
          }
          return WelcomePage();
        },
      ),
    );
  }
}

//
