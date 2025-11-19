import 'package:flutter/material.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';

class GameScreen extends StatelessWidget {
  final String code;

  const GameScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Screen - Lobby $code')),
      body: Center(
        child: Text('Game started for Lobby: $code'),
      ),
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.game,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}