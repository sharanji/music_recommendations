import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:spotify_recommendations/intro_screen.dart';
import 'package:spotify_recommendations/splash_screen.dart';
import 'package:spotify_recommendations/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: PRIMARYCOLOR),
  );
  cameras = await availableCameras();

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    ),
  );
}
