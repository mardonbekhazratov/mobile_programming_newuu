import 'package:flutter/material.dart';

/// Task 1: Selection Controls (Checkbox & Switch)
///
/// Exercise 1.1: a settings screen with a SwitchListTile for "Dark Mode"
/// and a CheckboxListTile for "Agree to Terms".
/// Exercise 1.2: toggling "Agree to Terms" enables or disables the
/// ElevatedButton below it.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _agreedToTerms = false;

  void _continue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms accepted. Settings saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The switch re-themes this screen so "Dark Mode" has a visible effect.
    return Theme(
      data: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('Use a dark color theme'),
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
            CheckboxListTile(
              secondary: const Icon(Icons.description_outlined),
              title: const Text('Agree to Terms'),
              subtitle: const Text('Required to continue'),
              value: _agreedToTerms,
              onChanged: (value) =>
                  setState(() => _agreedToTerms = value ?? false),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                // A null onPressed is how Flutter disables a button.
                onPressed: _agreedToTerms ? _continue : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
