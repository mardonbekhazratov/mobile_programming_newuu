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
import 'task3/task3_1.dart' as task3_1;
import 'task3/task3_2.dart' as task3_2;
import 'task3/task3_3.dart' as task3_3;
import 'task3/task3_4.dart' as task3_4;
import 'task3/task3_5.dart' as task3_5;
import 'task4/task4_1.dart' as task4_1;
import 'task4/task4_2.dart' as task4_2;
import 'task4/task4_3.dart' as task4_3;
import 'task4/task4_4.dart' as task4_4;
import 'task4/task4_5.dart' as task4_5;
import 'task5/task5_1.dart' as task5_1;
import 'task5/task5_2.dart' as task5_2;
import 'task5/task5_3.dart' as task5_3;
import 'task5/task5_4.dart' as task5_4;
import 'task5/task5_5.dart' as task5_5;
import 'task6/task6_1.dart' as task6_1;
import 'task6/task6_2.dart' as task6_2;
import 'task6/task6_3.dart' as task6_3;
import 'task6/task6_4.dart' as task6_4;
import 'task6/task6_5.dart' as task6_5;

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
          taskTile('3.1', 'Product list to product details', task3_1.app),
          taskTile('3.2', 'Greeting', task3_2.app),
          taskTile('3.3', 'Contact card', task3_3.app),
          taskTile('3.4', 'Pick a colour (result back)', task3_4.app),
          taskTile('3.5', 'Edit a counter', task3_5.app),
          taskTile('4.1', 'ScreenArguments class', task4_1.app),
          taskTile('4.2', 'Send a number', task4_2.app),
          taskTile('4.3', 'User profile', task4_3.app),
          taskTile('4.4', 'onGenerateRoute', task4_4.app),
          taskTile('4.5', 'Result from a named route', task4_5.app),
          taskTile('5.1', 'Fade transition', task5_1.app),
          taskTile('5.2', 'Slide from the right', task5_2.app),
          taskTile('5.3', 'Slide from the bottom', task5_3.app),
          taskTile('5.4', 'Scale and fade together', task5_4.app),
          taskTile('5.5', 'Reusable route and global theme', task5_5.app),
          taskTile('6.1', 'First router: go, push and pop', task6_1.app),
          taskTile('6.2', 'Path parameters', task6_2.app),
          taskTile('6.3', 'Passing an object with extra', task6_3.app),
          taskTile('6.4', 'Named routes and 404 page', task6_4.app),
          taskTile('6.5', 'Transition in go_router', task6_5.app),
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
