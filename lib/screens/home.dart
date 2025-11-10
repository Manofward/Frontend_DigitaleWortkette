import 'package:flutter/material.dart';
import '../services/navigation.dart';
import '../factories/screen_factory.dart';
import 'package:flutter_frontend/Widgets/custom_scaffold.dart';
import '../Widgets/open_games_list.dart';

class DWKHomePage extends StatelessWidget {
  const DWKHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digitale Wortkette')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ButtonCentered(
              label: 'Erstelle Spiel',
              icon: Icons.videogame_asset,
              onPressed: () => createGame(context),
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Offene Spiele',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Replaces your old list logic
            const OpenGamesList(),
          ],
        ),
      ),
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.home,
        onButtonPressed: (type) =>
            handleFooterButton(context, type, ScreenType.home),
      ),
    );
  }
}

