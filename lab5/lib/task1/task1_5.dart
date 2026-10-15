// Task 1.5 - Smart back button: enabled only if there is a screen to go back to
import 'package:flutter/material.dart';

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: HomeScreen());

class BackOrExitButton extends StatelessWidget {
  const BackOrExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return ElevatedButton(
      // onPressed: null makes the button disabled.
      onPressed: canPop ? () => Navigator.pop(context) : null,
      child: Text(canPop ? 'Back' : 'Nothing to go back to'),
    );
  }
}

// Root screen: the button is disabled here.
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
            const BackOrExitButton(),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Open second screen'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Pushed screen: the button is enabled here.
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second')),
      body: const Center(child: BackOrExitButton()),
    );
  }
}
