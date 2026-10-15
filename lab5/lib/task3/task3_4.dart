// Task 3.4 - Pick a colour: screen 2 returns a result to screen 1
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: SquareScreen());

class SquareScreen extends StatefulWidget {
  const SquareScreen({super.key});

  @override
  State<SquareScreen> createState() => _SquareScreenState();
}

class _SquareScreenState extends State<SquareScreen> {
  Color color = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Square')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 150, height: 150, color: color),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Choose colour'),
              onPressed: () async {
                final c = await Navigator.push<Color>(
                  context,
                  MaterialPageRoute(builder: (context) => const ColorScreen()),
                );
                // c is null if the user went back without choosing.
                if (c != null && mounted) setState(() => color = c);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ColorScreen extends StatelessWidget {
  const ColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose colour')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in [Colors.red, Colors.green, Colors.blue])
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: c),
                  onPressed: () => Navigator.pop(context, c),
                  child: const SizedBox(width: 80),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
