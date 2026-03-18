import 'package:flutter/material.dart';
import '../Widgets/footer_nav_bar.dart';
import '../utils/theme/app_theme.dart';
import '../factories/screen_factory.dart';
import '../services/navigation.dart';
import '../utils/get_username.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

}
class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = getUsername(); // gespeicherten Namen laden
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveUsername() {
    final name = _usernameController.text.trim();
    if (name.isEmpty) return;

    setUsername(name);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Username gespeichert")),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with the app title using themed styling
      appBar: AppBar(title: Text('Einstellungen', style: AppTheme.lightTheme.textTheme.titleLarge)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Dein Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveUsername,
                  ),
                ),
                onSubmitted: (_) => _saveUsername(),
              ),


          ],
        ),
      ),
      // Footer navigation bar with buttons for different app sections
      bottomNavigationBar: FooterNavigationBar(
        screenType: ScreenType.settings, // Indicates current screen for highlighting active button
        onButtonPressed: (type) => handleFooterButton(context, type), // Handles button taps
      ),
    );
  }
}