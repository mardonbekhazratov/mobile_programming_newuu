// Task 1.4 - Back to the start: Step 1 -> 2 -> 3 -> 4, Finish returns to Step 1
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: StepScreen(step: 1));

// One screen class is reused for all four steps.
class StepScreen extends StatelessWidget {
  final int step;
  const StepScreen({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Step $step')),
      body: Center(
        child: step < 4
            ? ElevatedButton(
                child: const Text('Next'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StepScreen(step: step + 1),
                    ),
                  );
                },
              )
            : ElevatedButton(
                child: const Text('Finish'),
                // Pops Steps 4, 3 and 2 at once, stops at the first screen.
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
      ),
    );
  }
}
