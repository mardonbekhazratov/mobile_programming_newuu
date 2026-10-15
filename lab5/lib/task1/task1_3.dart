// Task 1.3 - Replace, do not stack: after login you cannot go back to Login
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: LoginScreen());

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in'),
          onPressed: () {
            // pushReplacement removes Login from the stack.
            // Try Navigator.push here instead: Home will then have a back arrow.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
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
      body: const Center(
        child: Text('Welcome! There is no way back to Login.'),
      ),
    );
  }
}
