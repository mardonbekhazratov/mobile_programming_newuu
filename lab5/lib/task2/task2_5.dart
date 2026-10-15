// Task 2.5 - Log out: go to /login and clear the whole stack
import 'package:flutter/material.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
}

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  // MaterialApp needs a first screen ("/"). We use `home` for it,
  // because our routes start with /login, not /.
  home: const LoginScreen(),
  routes: {
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.profile: (context) => const ProfileScreen(),
  },
);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in'),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Profile'),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Log out'),
          onPressed: () {
            // Push /login and remove every screen below it
            // ((route) => false means "keep none of them").
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
