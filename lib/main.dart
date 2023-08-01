// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:learning_text_recognition/learning_text_recognition.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Scalable OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textRecognition = TextRecognition();
  bool _isProcessing = false;
  final nameRegex =
      RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  final phNoRegex = RegExp(r"[0-9]");

  List<String> name = [];
  List<String> email = [];
  List<String> phNo = [];
  List<String> address = [];
  String text = "";

  @override
  void dispose() {
    _textRecognition.dispose();
    super.dispose();
  }

  Future<void> _startRecognition(InputImage image) async {
    text = "";
    name.clear();
    email.clear();
    phNo.clear();
    address.clear();
    if (!_isProcessing) {
      _isProcessing = true;
      final data = await _textRecognition.process(image);
      for (final i in data!.blocks) {
        if (i.lines.length > 1) {
          for (final j in i.lines) {
            if (i.text.contains(":")) {
              text = j.text.split(":").removeLast().trim();
            } else {
              text = "";
            }
            addText(text.isEmpty ? j.text : text);
          }
        } else {
          if (i.text.contains(":")) {
            text = i.text.split(":").removeLast().trim();
          } else {
            text = "";
          }
          addText(text.isEmpty ? i.text : text);
        }
      }
      _isProcessing = false;
    }
    setState(() {});
  }

  void addText(String text) {
    if (nameRegex.hasMatch(text)) {
      name.add(text);
    } else if (emailRegex.hasMatch(text)) {
      email.add(text);
    } else if (text.startsWith(phNoRegex)) {
      phNo.add(text);
    } else {
      address.add(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InputCameraView(
              mode: InputCameraMode.gallery,
              resolutionPreset: ResolutionPreset.max,
              title: 'Text Recognition',
              onImage: _startRecognition,
              canSwitchMode: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Column(
              children: [
                Text(
                  "Name: ${name.join(" ")}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Email: ${email.join(" ")}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "PhNo: ${phNo.join(" ")}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Address: ${address.join(" ")}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
