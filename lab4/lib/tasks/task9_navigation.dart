import 'package:flutter/material.dart';

/// Task 9: Navigation Controls (BottomNavigationBar & TabBar)
///
/// Exercise 9.1: a BottomNavigationBar with 3 tabs that switches the view
/// shown in the body.
/// Exercise 9.2: the News view has top tabs, a TabBar inside the AppBar
/// paired with a TabBarView in the body.
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int _selectedIndex = 0;

  static const _titles = ['News', 'Saved', 'Profile'];
  static const _categories = ['World', 'Tech', 'Sports'];

  @override
  Widget build(BuildContext context) {
    // The TabBar and TabBarView find their shared controller by looking up
    // the widget tree, so DefaultTabController must sit above both of them.
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          // Only the News view has top tabs.
          bottom: _selectedIndex == 0
              ? TabBar(tabs: [for (final c in _categories) Tab(text: c)])
              : null,
        ),
        body: switch (_selectedIndex) {
          0 => TabBarView(
            children: [for (final c in _categories) _HeadlineList(c)],
          ),
          1 => const _EmptyView(
            icon: Icons.bookmark_border,
            text: 'No saved articles yet',
          ),
          _ => const _EmptyView(
            icon: Icons.person_outline,
            text: 'Sign in to see your profile',
          ),
        },
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              activeIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/// The content of one top tab: a list of headlines for a news category.
class _HeadlineList extends StatelessWidget {
  final String category;

  const _HeadlineList(this.category);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.article_outlined),
        title: Text('$category headline ${index + 1}'),
        subtitle: Text('${index + 2} min read'),
      ),
    );
  }
}

/// A centered icon and message for views that have no content yet.
class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyView({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: 12.0),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
