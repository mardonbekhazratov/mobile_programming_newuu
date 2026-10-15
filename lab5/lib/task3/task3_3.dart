// Task 3.3 - Contact card: the whole Contact object is passed, not three strings
import 'package:flutter/material.dart';

class Contact {
  final String name;
  final String phone;
  final String email;
  const Contact(this.name, this.phone, this.email);
}

const contacts = [
  Contact('Alice', '+998 90 111 11 11', 'alice@mail.com'),
  Contact('Bob', '+998 90 222 22 22', 'bob@mail.com'),
  Contact('Carol', '+998 90 333 33 33', 'carol@mail.com'),
  Contact('Dave', '+998 90 444 44 44', 'dave@mail.com'),
  Contact('Eve', '+998 90 555 55 55', 'eve@mail.com'),
];

void main() => runApp(app);

// Also used by lib/main.dart to open this task from the menu.
const app = MaterialApp(home: ContactListScreen());

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView(
        children: [
          for (final c in contacts)
            ListTile(
              title: Text(c.name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactScreen(contact: c),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  final Contact contact;
  const ContactScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(contact.name),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(contact.phone),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(contact.email),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
