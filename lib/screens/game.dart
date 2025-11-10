import 'package:flutter/material.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Screen')),
      body: const Center(
        child: Text('Game started!'),
      ),
      // usage of the footer bar
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.game,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}
