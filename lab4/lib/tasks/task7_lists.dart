import 'package:flutter/material.dart';

/// Task 7: Scrollable Collections (ListView.builder & ListTile)
///
/// Exercise 7.1: a list of 20 items built lazily with ListView.builder,
/// each rendered as a ListTile.
/// Exercise 7.2: each item is wrapped in a Dismissible so it can be swiped
/// away.
class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final List<int> _items = List.generate(20, (index) => index + 1);

  void _dismiss(int item) {
    setState(() => _items.remove(item));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Item $item dismissed'),
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              // Sorting puts the item back in its original position.
              setState(
                () => _items
                  ..add(item)
                  ..sort(),
              );
            },
          ),
        ),
      );
  }

  /// The red area revealed behind a tile while it is being swiped.
  Widget _swipeBackground(Alignment alignment) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.errorContainer,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: _items.isEmpty
          ? const Center(child: Text('All items dismissed'))
          // builder only creates the tiles that are currently on screen.
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  // The key identifies the item, not its position, so Flutter
                  // knows exactly which tile was swiped away.
                  key: ValueKey(item),
                  background: _swipeBackground(Alignment.centerLeft),
                  secondaryBackground: _swipeBackground(Alignment.centerRight),
                  onDismissed: (_) => _dismiss(item),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('$item')),
                    title: Text('Item $item'),
                    subtitle: const Text('Swipe left or right to dismiss'),
                  ),
                );
              },
            ),
    );
  }
}
