import 'package:flutter/material.dart';
import 'package:flutter_frontend/Widgets/custom_scaffold.dart';
import 'package:flutter_frontend/services/navigation.dart';
import 'package:flutter_frontend/factories/screen_factory.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digitale Wortkette Regeln')),
      body: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: 
          Text('Hello World'),
        )
      ),
      bottomNavigationBar: FooterNavigationBar (
        screenType: ScreenType.manual,
        onButtonPressed: (type) => handleFooterButton(context, type, ScreenType.manual),
      ),
    );
  }
}