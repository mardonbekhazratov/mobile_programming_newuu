// Task 5.5 - Reusable FadeRoute and a global page transition theme
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  // Part 2: every normal MaterialPageRoute now uses the iOS-style
  // slide on Android too, without writing any custom route.
  // The map replaces all defaults, so macOS is listed to keep its
  // Cupertino slide (otherwise it falls back to the zoom transition).
  theme: ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  ),
  home: const HomeScreen(),
);

// Part 1: a reusable route, so any screen can fade in with one line.
class FadeRoute extends PageRouteBuilder<void> {
  FadeRoute(Widget page)
    : super(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
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
              child: const Text('FadeRoute'),
              onPressed: () =>
                  Navigator.push(context, FadeRoute(const DetailsScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('MaterialPageRoute (theme)'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailsScreen()),
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
      body: const Center(child: Text('Details')),
    );
  }
}
