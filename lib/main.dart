import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wipeswipe/app.dart';
import 'package:wipeswipe/observer.dart';

void main() {
  Bloc.observer = GlobalObserver();
  runApp(MyApp());
}
