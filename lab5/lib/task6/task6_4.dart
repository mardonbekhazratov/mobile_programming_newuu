// Task 6.4 - Named routes and a 404 page
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomeScreen(),
      // Sub-routes are stacked on top of Home, so they get a back arrow.
      routes: [
        GoRoute(
          name: 'settings',
          path: 'settings',
          builder: (context, state) => const PageScreen('Settings'),
        ),
        GoRoute(
          name: 'item',
          path: 'item/:id',
          builder: (context, state) =>
              PageScreen('Item ${state.pathParameters['id']}'),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const PageScreen('Page not found'),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.goNamed('settings'),
              child: const Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () =>
                  context.goNamed('item', pathParameters: {'id': '42'}),
              child: const Text('Item 42'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/does-not-exist'),
              child: const Text('Broken link'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageScreen extends StatelessWidget {
  final String title;
  const PageScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.goNamed('home'),
          child: const Text('Home'),
        ),
      ),
    );
  }
}
