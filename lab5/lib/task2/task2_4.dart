// Task 2.4 - Drawer navigation with pushReplacementNamed
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
    AppRoutes.home: (context) => const PageScreen('Home'),
    AppRoutes.profile: (context) => const PageScreen('Profile'),
    AppRoutes.messages: (context) => const PageScreen('Messages'),
    AppRoutes.about: (context) => const PageScreen('About'),
  },
);

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          drawerItem(context, 'Home', AppRoutes.home),
          drawerItem(context, 'Profile', AppRoutes.profile),
          drawerItem(context, 'Messages', AppRoutes.messages),
          drawerItem(context, 'About', AppRoutes.about),
        ],
      ),
    );
  }

  Widget drawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close the drawer first
        // Replace the current screen, so the stack always has one screen.
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}

// Every section uses the same screen with the drawer,
// so the user can switch sections from anywhere.
class PageScreen extends StatelessWidget {
  final String title;
  const PageScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: Center(child: Text('This is the $title screen')),
    );
  }
}
