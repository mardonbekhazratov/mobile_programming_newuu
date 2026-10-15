// Task 6.3 - Passing an object with extra
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Product, the product list and ProductScreen from Category 3.
import '../task3/task3_1.dart' show Product, products, ProductScreen;

// extra lives only in memory. After a browser reload the URL is still
// /product-details but extra is null, so the cast below fails.
// A path parameter (/product/1) is part of the URL itself, so it survives
// reloads, deep links and bookmarks.
GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/product-details',
      builder: (context, state) =>
          ProductScreen(product: state.extra as Product),
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
      appBar: AppBar(title: const Text('Products')),
      body: ListView(
        children: [
          for (final p in products)
            ListTile(
              title: Text(p.name),
              subtitle: Text('\$${p.price}'),
              onTap: () => context.push('/product-details', extra: p),
            ),
        ],
      ),
    );
  }
}
