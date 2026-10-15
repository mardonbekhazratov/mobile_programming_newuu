// Task 4.4 - onGenerateRoute instead of a routes table
import 'package:flutter/material.dart';

// Same users list and home screen as Task 4.3.
import 'task4_3.dart' show User, HomeScreen;

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  initialRoute: '/',
  onGenerateRoute: (settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    }
    final args = settings.arguments;
    if (settings.name == '/profile' && args is User) {
      // The User is passed with the constructor, so it is type-safe.
      return MaterialPageRoute(builder: (context) => ProfileScreen(user: args));
    }
    return null;
  },
);

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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
