import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';
import 'package:flutter_frontend/Widgets/custom_scaffold.dart';
import '../Widgets/open_games_list.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';

class DWKHomePage extends StatelessWidget {
  const DWKHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digitale Wortkette', style: AppTheme.lightTheme.textTheme.headlineLarge)),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Offene Spiele',
                style: AppTheme.lightTheme.textTheme.titleLarge,
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

