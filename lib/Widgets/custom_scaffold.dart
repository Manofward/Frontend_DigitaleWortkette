import 'package:flutter/material.dart';
import '../factories/screen_factory.dart';
import '../factories/footer_factory.dart';

// Button Centeredrtop
class ButtonCentered extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ButtonCentered({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// completed navigationbar:
// creates uses _FooterButton to get the buttons
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
    final footerButtons = FooterButtonConfig.forScreen(screenType);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0), // static color avoids color[200] lookup
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final btn in footerButtons)
            _FooterButton(
              config: btn,
              onPressed: () => onButtonPressed?.call(btn.type),
            ),
        ],
      ),
    );
  }
}

// this class is the building process of one button that will be used in the footer navigation bar
class _FooterButton extends StatelessWidget {
  final FooterButtonConfig config;
  final VoidCallback onPressed;

  const _FooterButton({
    required this.config,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: Colors.blueAccent, size: 28),
            const SizedBox(height: 4),
            Text(
              config.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
