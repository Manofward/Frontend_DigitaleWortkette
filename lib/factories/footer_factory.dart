import 'package:flutter/material.dart';
import 'screen_factory.dart';

/// Types of footer buttons available
enum FooterButtonType { settings, manual, qrScanner, home }

/// Model defining a footer button
class FooterButtonConfig {
  final IconData icon;
  final String label;
  final FooterButtonType type;

  const FooterButtonConfig({
    required this.icon,
    required this.label,
    required this.type,
  });

  /// Static factory method for footer buttons by screen
  static List<FooterButtonConfig> forScreen(ScreenType screen) {
    final buttons = <FooterButtonConfig>[
      const FooterButtonConfig(
        icon: Icons.settings,
        label: 'Einstellungen',
        type: FooterButtonType.settings,
      ),
      const FooterButtonConfig(
        icon: Icons.menu_book,
        label: 'Anleitung',
        type: FooterButtonType.manual,
      ),
    ];

    if (screen == ScreenType.home) {
      buttons.add(const FooterButtonConfig(
        icon: Icons.qr_code_scanner,
        label: 'QR-Code Scanner',
        type: FooterButtonType.qrScanner,
      ));
    } else {
      buttons.add(const FooterButtonConfig(
        icon: Icons.home,
        label: 'Startseite',
        type: FooterButtonType.home,
      ));
    }

    return buttons;
  }
}
