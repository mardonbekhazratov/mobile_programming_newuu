// Task 2.2 - Menu with four routes: /, /profile, /messages, /about
import 'package:flutter/material.dart';

class AppRoutes {
  static const home = '/';
  static const profile = '/profile';
  static const messages = '/messages';
  static const about = '/about';
}

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  initialRoute: AppRoutes.home,
  routes: {
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.profile: (context) => const PageScreen('Profile'),
    AppRoutes.messages: (context) => const PageScreen('Messages'),
    AppRoutes.about: (context) => const PageScreen('About'),
  },
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Profile'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          ListTile(
            title: const Text('Messages'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
          ),
          ListTile(
            title: const Text('About'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

// One simple screen reused for Profile, Messages and About.
class PageScreen extends StatelessWidget {
  final String title;
  const PageScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title screen')),
    );
  }
}
