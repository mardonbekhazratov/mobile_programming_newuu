import 'package:flutter/material.dart';

/// Task 10: Structural Containers (Card & ExpansionTile)
///
/// Exercise 10.1: an information Card with a header, subtitle, leading Icon
/// and trailing action button.
/// Exercise 10.2: an FAQ section made of ExpansionTiles that expand and
/// collapse their answers when tapped.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _faqs = [
    (
      question: 'How do I reset my password?',
      answer:
          'Tap "Forgot password?" on the login screen and enter your email. '
          'We will send you a link to choose a new password.',
    ),
    (
      question: 'Can I use the app offline?',
      answer:
          'Yes. Content you have already opened stays available offline. '
          'New content loads the next time you are connected.',
    ),
    (
      question: 'How do I change the app language?',
      answer:
          'The app follows your device language. Change it in your phone '
          'settings and the app updates the next time it opens.',
    ),
    (
      question: 'How do I delete my account?',
      answer:
          'Open Settings, then Account, then Delete account. Deleting is '
          'permanent and removes all of your data.',
    ),
    (
      question: 'Is my data shared with anyone?',
      answer:
          'No. Your data is only used to run the app and is never sold or '
          'shared with third parties.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card gives the content an elevated, rounded surface; ListTile
          // lays out the leading icon, header, subtitle and trailing button.
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Icon(
                Icons.support_agent,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              title: Text('Need more help?', style: theme.textTheme.titleLarge),
              subtitle: const Text('Our support team replies within 24 hours.'),
              trailing: IconButton.filledTonal(
                tooltip: 'Contact support',
                icon: const Icon(Icons.chat_outlined),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening chat with support...')),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8.0),
          for (final faq in _faqs)
            ExpansionTile(
              leading: const Icon(Icons.help_outline),
              title: Text(faq.question),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              childrenPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              children: [Text(faq.answer)],
            ),
        ],
      ),
    );
  }
}
