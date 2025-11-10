import 'package:flutter/material.dart';
import 'package:flutter_frontend/Widgets/custom_scaffold.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Screen')),
      body: const Center(
        child: Text('Game started!'),
      ),
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.game,
        onButtonPressed: (type) => handleFooterButton(context, type, ScreenType.game),
      ),
    );
  }
}
