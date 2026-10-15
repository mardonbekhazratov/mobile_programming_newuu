// Task 2.3 - Page not found: unknown route names open a 404 screen
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  initialRoute: '/',
  routes: {'/': (context) => const HomeScreen()},
  // Called when pushNamed gets a name that is not in the routes table.
  onUnknownRoute: (settings) =>
      MaterialPageRoute(builder: (context) => const NotFoundScreen()),
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open a missing page'),
          onPressed: () => Navigator.pushNamed(context, '/does-not-exist'),
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
