import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/navigation.dart';
import 'package:flutter_frontend/factories/screen_factory.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';

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
          child: RichText(
            text: TextSpan(
              style: AppTheme.lightTheme.textTheme.bodyLarge,
              children: <TextSpan>[
                TextSpan(text: 'Bilde ein Wort mit dem letzten Buchstaben des vorherigen Wortes.'),
                
                const TextSpan(text: '\n\n'),
                
                TextSpan(text: 'Zum Beispiel haben wir zwei Spieler. Spieler 1 gibt das Wort '),
                TextSpan(text: 'Elefant ', style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary)),
                TextSpan(text: 'ein.'),

                const TextSpan(text: '\n\n'),

                TextSpan(text: 'Daraufhin muss der Spieler 2 mit einem Wort welches mit dem letzten Buchstaben von dem Wort Elefant eingeben. \nIn diesem Fall wäre der Buchstabe ein '),
                TextSpan(text: 'T', style: TextStyle(color: AppTheme.lightTheme.colorScheme.secondary)),
                TextSpan(text: '.'),

                const TextSpan(text: '\n\n'),

                TextSpan(text: 'Dies Würde ungefähr so aussehen: '),
                TextSpan(text: 'Elefant, Tiger, Rhinozeros, Schimpanse ...', style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary)),

                const TextSpan(text: '\n\n\n'),

                TextSpan(text: 'Hierbei muss man auch darauf achten welches Thema es ist. Weil man ein Tier nicht beim Thema Programiersprachen genutzt werden darf.'),
              ],
            ),
          ),
        )
      ),
      // usage of the footer bar
      bottomNavigationBar: FooterNavigationBar (
        screenType: ScreenType.manual,
        onButtonPressed: (type) => handleFooterButton(context, type),
      ),
    );
  }
}