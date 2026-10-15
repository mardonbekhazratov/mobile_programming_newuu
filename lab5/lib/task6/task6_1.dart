// Task 6.1 - First router: go, push and pop (solved example)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/details',
      builder: (context, state) => const DetailsScreen(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/details'),
              child: const Text('go (replace stack)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/details'),
              child: const Text('push (add to stack)'),
            ),
          ],
        ),
      ),
    );
  }
}

// After go the stack is only [Details] (both routes are top-level),
// so there is no back arrow and pop has nothing to pop.
// After push the stack is [Home, Details], so pop works.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              // context.pop() throws if there is nothing to pop,
              // so the button is disabled after go.
              onPressed: context.canPop() ? () => context.pop() : null,
              child: const Text('pop'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('go home'),
            ),
          ],
        ),
      ),
    );
  }
}
