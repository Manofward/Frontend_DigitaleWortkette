import 'package:flutter/material.dart';
import '../utils/theme/app_theme.dart';

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
        icon: Icon(icon, size: 28, color: AppTheme.lightTheme.colorScheme.secondary),
        label: Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.lightTheme.colorScheme.secondary),
        ),
      ),
    );
  }
}
