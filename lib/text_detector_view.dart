import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'theme.dart';
import 'package:spotify_recommendations/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './camera_view.dart';

import 'package:text_analysis/text_analysis.dart';

class TextRecognizerView extends StatefulWidget {
  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String _text = '';
  Widget _dataWidget = const SizedBox();
  List<InputImage> inputImages = [];

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Sabari',
      customPaint: _customPaint,
      text: _text,
      imagesLength: inputImages.length,
      dataWidget: _dataWidget,
      onReset: () {
        inputImages = [];
        setState(() {
          _dataWidget = const SizedBox();
        });
      },
      onProcced: () {
        processImage();
      },
      onImage: (InputImage inputImage) {
        inputImages.add(inputImage);
        previewImages(true);
      },
    );
  }

  Future<Widget> previewImages(canSetsate) async {
    Widget previewImages = Column(
      children: [
        SingleChildScrollView(
          physics: const PageScrollPhysics(),
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...inputImages.map((_image) {
                return SizedBox(
                  height: 300,
                  width: (MediaQuery.of(context).size.width) - 30,
                  child: Image.file(
                    File(_image.filePath!),
                    fit: BoxFit.fitWidth,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
    if (canSetsate) {
      setState(() {
        _dataWidget = previewImages;
      });
    }

    return previewImages;
  }

  Future<void> processImage() async {
    setState(() {
      _text = '';
    });

    InputImage selectedImage = inputImages[0];

    final bytes = File(selectedImage.filePath!).readAsBytesSync();
    String base64Image = base64Encode(bytes);

    setState(() {
      _dataWidget = CupertinoActivityIndicator();
      inputImages = [];
    });

    var response = await http.post(
      Uri.parse('http://192.168.18.58:5000/upload'),
      body: jsonEncode(
        {
          'image': base64Image,
        },
      ),
    );
    var responseBody = jsonDecode(response.body);
    _customPaint = null;

    try {
      Widget previewImage = await previewImages(false);
      _dataWidget = Column(
        children: [
          previewImage,
          Column(
            children: [
              for (int i = 0; i < responseBody.length; i++)
                ListBody(
                  children: [
                    ListTile(
                      isThreeLine: true,
                      leading: CircleAvatar(
                        child: Text(responseBody[i]['name'][0]),
                      ),
                      title: Text(responseBody[i]['name']),
                      subtitle: Text(responseBody[i]['artists']),
                      trailing: const Icon(Icons.play_arrow),
                    ),
                    const Divider(),
                  ],
                ),
            ],
          ),
        ],
      );

      inputImages = [];
    } catch (e) {
      print(e.toString() + 'error asdf');
    }

    setState(() {});
  }
}
