// Task 4.3 - User profile: /profile gets a User object as its argument
import 'package:flutter/material.dart';

class User {
  final String name;
  final int age;
  final String city;
  const User(this.name, this.age, this.city);
}

const users = [
  User('Alice', 21, 'Tashkent'),
  User('Bob', 25, 'Samarkand'),
  User('Carol', 19, 'Bukhara'),
  User('Dave', 30, 'Namangan'),
];

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const HomeScreen(),
    '/profile': (context) => const ProfileScreen(),
  },
);

// Also used by Task 4.4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView(
        children: [
          for (final u in users)
            ListTile(
              title: Text(u.name),
              onTap: () =>
                  Navigator.pushNamed(context, '/profile', arguments: u),
            ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Center(
        child: Text(
          'Name: ${user.name}\nAge: ${user.age}\nCity: ${user.city}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
