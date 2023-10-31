import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'intro_screen.dart';
import 'text_detector_view.dart';
import 'theme.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = "/splash";
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      authCheck();
    });
  }

  Future<void> authCheck() async {
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return TextRecognizerView();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/logo.png',
            //   fit: BoxFit.fitWidth,
            // ),
            const SizedBox(
              height: 40,
              child: CupertinoActivityIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
