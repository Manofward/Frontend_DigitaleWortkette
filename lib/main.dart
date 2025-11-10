import 'package:flutter/material.dart';
import 'factories/screen_factory.dart';

void main() {
  runApp(const DWKApp());
}

class DWKApp extends StatelessWidget {
  const DWKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitale Wortkette Client',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ScreenFactory.createScreen(ScreenType.home),
    );
  }
}