// Task 5.3 - Slide from the bottom: a second button opens the screen as a sheet
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: HomeScreen());

// Builds a route that slides the details screen in from `begin`.
Route<void> slideRoute(Offset begin, Duration duration, Curve curve) {
  return PageRouteBuilder(
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) =>
        const DetailsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve)),
        child: child,
      );
    },
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Open with slide'),
              onPressed: () => Navigator.push(
                context,
                slideRoute(
                  const Offset(1, 0),
                  const Duration(milliseconds: 400),
                  Curves.linear,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Open as a sheet'),
              onPressed: () => Navigator.push(
                context,
                slideRoute(
                  const Offset(0, 1), // starts below the bottom edge
                  const Duration(milliseconds: 500),
                  Curves.easeOut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: const Center(child: Text('I slid in!')),
    );
  }
}
