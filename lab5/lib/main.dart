// Menu with all tasks, so every task can be tested in one run.
import 'package:flutter/material.dart';

import 'task1/task1_1.dart' as task1_1;
import 'task1/task1_2.dart' as task1_2;
import 'task1/task1_3.dart' as task1_3;
import 'task1/task1_4.dart' as task1_4;
import 'task1/task1_5.dart' as task1_5;
import 'task2/task2_1.dart' as task2_1;
import 'task2/task2_2.dart' as task2_2;
import 'task2/task2_3.dart' as task2_3;
import 'task2/task2_4.dart' as task2_4;
import 'task2/task2_5.dart' as task2_5;

void main() => runApp(const MaterialApp(home: MenuScreen()));

// Replaces the menu with the app of one task.
// The floating button runs main() again, which brings the menu back.
void openTask(Widget app) {
  runApp(
    MaterialApp(
      // A new key makes Flutter build a fresh app instead of reusing the menu.
      key: UniqueKey(),
      home: Scaffold(
        body: app,
        floatingActionButton: FloatingActionButton(
          onPressed: main,
          child: const Icon(Icons.list),
        ),
      ),
    ),
  );
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 5: Navigation')),
      body: ListView(
        children: [
          taskTile('1.1', 'Two screens with push and pop', task1_1.app),
          taskTile('1.2', 'Three-screen chain', task1_2.app),
          taskTile('1.3', 'Replace, do not stack', task1_3.app),
          taskTile('1.4', 'Back to the start', task1_4.app),
          taskTile('1.5', 'Smart back button', task1_5.app),
          taskTile('2.1', 'Route table and pushNamed', task2_1.app),
          taskTile('2.2', 'Menu with four routes', task2_2.app),
          taskTile('2.3', 'Page not found', task2_3.app),
          taskTile('2.4', 'Drawer navigation', task2_4.app),
          taskTile('2.5', 'Log out', task2_5.app),
        ],
      ),
    );
  }

  Widget taskTile(String number, String name, Widget app) {
    return ListTile(
      title: Text('Task $number'),
      subtitle: Text(name),
      onTap: () => openTask(app),
    );
  }
}
