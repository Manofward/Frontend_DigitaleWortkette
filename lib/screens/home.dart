import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';
import 'package:flutter_frontend/Widgets/custom_scaffold.dart';
import '../Widgets/open_games_list.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';

// Home page widget for the Digitale Wortkette app
// Displays the main interface with options to create games and join existing ones
class DWKHomePage extends StatelessWidget {
  const DWKHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with the app title using themed styling
      appBar: AppBar(title: Text('Digitale Wortkette', style: AppTheme.lightTheme.textTheme.headlineLarge)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Centered button to create a new game
            ButtonCentered(
              label: 'Erstelle Spiel',
              icon: Icons.videogame_asset,
              onPressed: () => createGame(context), // Calls function to create and navigate to new game
            ),
            const SizedBox(height: 32), // Spacing between sections
            // Left-aligned title for the open games section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Offene Spiele',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16), // Spacing before the list

            // Expanded widget to make the games list take remaining vertical space
            Expanded(
              child: const OpenGamesList(), // Displays list of available games to join
            ),
          ],
        ),
      ),
      // Footer navigation bar with buttons for different app sections
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.home, // Indicates current screen for highlighting active button
        onButtonPressed: (type) => handleFooterButton(context, type), // Handles button taps
      ),
    );
  }
}

