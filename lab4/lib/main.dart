import 'package:flutter/material.dart';

import 'tasks/task1_selection_controls.dart';
import 'tasks/task2_input_fields.dart';
import 'tasks/task3_buttons.dart';
import 'tasks/task4_indicators.dart';
import 'tasks/task5_dialogs.dart';
import 'tasks/task6_sliders_pickers.dart';
import 'tasks/task7_lists.dart';
import 'tasks/task8_grids.dart';
import 'tasks/task9_navigation.dart';
import 'tasks/task10_containers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4: Flutter Widgets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

/// One entry of the home menu: a lab task and the page that implements it.
class _Task {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  const _Task(this.title, this.subtitle, this.icon, this.page);
}

/// Home screen that lists every task and opens its page on tap.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _tasks = [
    _Task(
      'Task 1: Selection Controls',
      'SwitchListTile & CheckboxListTile',
      Icons.toggle_on_outlined,
      SettingsPage(),
    ),
    _Task(
      'Task 2: Input Fields',
      'TextFormField & validation',
      Icons.password,
      LoginPage(),
    ),
    _Task(
      'Task 3: Buttons & Action Items',
      'FloatingActionButton & OutlinedButton',
      Icons.touch_app_outlined,
      CounterPage(),
    ),
    _Task(
      'Task 4: Indicators & Feedback',
      'CircularProgressIndicator & SnackBar',
      Icons.hourglass_empty,
      UploadPage(),
    ),
    _Task(
      'Task 5: Dialogs & Modals',
      'AlertDialog & showModalBottomSheet',
      Icons.chat_bubble_outline,
      FilesPage(),
    ),
    _Task(
      'Task 6: Sliders & Pickers',
      'Slider & showDatePicker',
      Icons.tune,
      VolumePage(),
    ),
    _Task(
      'Task 7: Scrollable Collections',
      'ListView.builder & Dismissible',
      Icons.list,
      ItemListPage(),
    ),
    _Task(
      'Task 8: Grid Displays',
      'GridView.count & full-screen preview',
      Icons.grid_view,
      GalleryPage(),
    ),
    _Task(
      'Task 9: Navigation Controls',
      'BottomNavigationBar & TabBar',
      Icons.tab_outlined,
      NewsPage(),
    ),
    _Task(
      'Task 10: Structural Containers',
      'Card & ExpansionTile',
      Icons.view_agenda_outlined,
      HelpPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 4: Flutter Widgets')),
      body: ListView.separated(
        itemCount: _tasks.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Icon(task.icon),
            title: Text(task.title),
            subtitle: Text(task.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => task.page)),
          );
        },
      ),
    );
  }
}
