// Task 3.5 - Edit a counter: Save returns the new value, back arrow keeps the old
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: CounterScreen());

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$counter', style: const TextStyle(fontSize: 48)),
            ElevatedButton(
              child: const Text('Edit'),
              onPressed: () async {
                final result = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditorScreen(value: counter),
                  ),
                );
                // null means the back arrow was used: keep the old value.
                if (result != null && mounted) {
                  setState(() => counter = result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  final int value;
  const EditorScreen({super.key, required this.value});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late int value = widget.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() => value--),
                ),
                Text('$value', style: const TextStyle(fontSize: 48)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => value++),
                ),
              ],
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );
  }
}
