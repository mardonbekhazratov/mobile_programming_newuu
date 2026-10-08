import 'package:flutter/material.dart';

/// Task 3: Buttons & Action Items (FloatingActionButton & ElevatedButton)
///
/// Exercise 3.1: a counter screen whose FloatingActionButton in the bottom
/// corner increments the counter.
/// Exercise 3.2: a secondary OutlinedButton resets the counter back to 0.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You have pressed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24.0),
            OutlinedButton.icon(
              // Nothing to reset while the counter is already 0.
              onPressed: _counter == 0
                  ? null
                  : () => setState(() => _counter = 0),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
      // The default location (endFloat) is the bottom-right corner.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        onPressed: () => setState(() => _counter++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
