import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';

enum FooterButtonType { settings, manual, qrScanner, home } // This has the definitions for the Footer Buttons

class FooterNavigationBar extends StatelessWidget {
  final ScreenType screenType;
  final ValueChanged<FooterButtonType>? onButtonPressed;

  const FooterNavigationBar({
    super.key,
    required this.screenType,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // All buttons in one simple list
    final buttons = [
      {'icon': Icons.home, 'label': 'Startseite', 'type': FooterButtonType.home},
      {'icon': Icons.settings, 'label': 'Einstellungen', 'type': FooterButtonType.settings},
      {'icon': Icons.menu_book, 'label': 'Anleitung', 'type': FooterButtonType.manual},
      {'icon': Icons.qr_code_scanner, 'label': 'QR-Code Scanner', 'type': FooterButtonType.qrScanner},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // the buttons are created above in the final buttons and uses the _isActive to determine if it should be highlighted
        children: buttons.map((btn) {
          final type = btn['type'] as FooterButtonType;
          final isActive = _isActive(type);

          return InkWell(
            onTap: () => onButtonPressed?.call(type),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(btn['icon'] as IconData, color: isActive ? Colors.blue : Colors.grey, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    btn['label'] as String,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isActive ? Colors.blue : Colors.grey,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // is the verification what page your on
  bool _isActive(FooterButtonType type) {
    switch (screenType) {
      case ScreenType.home:
        return type == FooterButtonType.home;
      case ScreenType.manual:
        return type == FooterButtonType.manual;
      case ScreenType.game:
        return type == FooterButtonType.home;
      default:
        return false;
    }
  }
}
