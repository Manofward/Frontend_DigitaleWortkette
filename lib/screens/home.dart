/* TODOs:
1. The Title: "Digitale Wortkette" and "offene Spiele" have to be edited so that maybe the big title is similar to the other
2. linkings to the settings page and qr-Code scanner have to be made and the pages itself too
3. when you go from host-lobby page back to homepage through the back or home button the lobby needs to be deleted
4. when you go from the host-lobby page to home you need to get the automatic gamelist updates
*/
import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';
import 'package:flutter_frontend/Widgets/custom_scaffold.dart';
import '../Widgets/open_games_list.dart';
import '../Widgets/footer_nav_bar.dart';

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

            // Wrap ListView in Expanded
            Expanded(
              child: const OpenGamesList(),
            ),
          ],
        ),
      ),
      // usage of the footer bar
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.home,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}

