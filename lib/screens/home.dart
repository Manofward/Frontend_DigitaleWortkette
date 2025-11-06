import 'package:flutter/material.dart';
import '../Widgets/custom_scaffold.dart'; // Import reusable button
import '../services/navigation.dart';

class DWKHomePage extends StatelessWidget {
  const DWKHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digitale Wortkette'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: ButtonCentered(
            label: 'Erstelle Spiel',
            icon: Icons.videogame_asset,
            onPressed: createGame,
          ),
        ),
      ),
    );
  }
}

