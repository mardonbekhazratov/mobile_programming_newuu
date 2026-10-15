// Task 6.5 - Transition in go_router with CustomTransitionPage
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// One helper for all routes: slide from the right while scaling 80% -> 100%.
// state.pageKey lets go_router tell the pages apart.
Page<void> buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}

GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => buildPage(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/details',
      pageBuilder: (context, state) => buildPage(state, const DetailsScreen()),
    ),
  ],
);

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
// A getter makes a new router every time, so the task always starts at '/'.
Widget get app => MaterialApp.router(routerConfig: createRouter());

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/details'),
          child: const Text('Open details'),
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
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('pop'),
        ),
      ),
    );
  }
}
