// Task 4.5 - Result from a named route: /rate returns a rating from 1 to 5
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
final app = MaterialApp(
  home: const HomeScreen(),
  // pushNamed<int> needs a Route<int>. The routes table always builds
  // MaterialPageRoute<dynamic>, so /rate is created here instead.
  onGenerateRoute: (settings) {
    if (settings.name == '/rate') {
      return MaterialPageRoute<int>(
        settings: settings,
        builder: (context) => const RateScreen(),
      );
    }
    return null;
  },
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating == null ? 'Movie: not rated' : 'Movie: $rating/5',
              style: const TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              child: const Text('Rate'),
              onPressed: () async {
                final result = await Navigator.pushNamed<int>(
                  context,
                  '/rate',
                  arguments: 'Movie',
                );
                // The back arrow returns null, so Home keeps the old rating
                // (or "not rated" if there was none).
                if (result != null && mounted) setState(() => rating = result);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RateScreen extends StatelessWidget {
  const RateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text('Rate $title')),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );
  }
}
