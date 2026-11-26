import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../data/product_api.dart';
import '../widgets/message_view.dart';
import '../widgets/product_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (c) => SearchBloc(c.read<ProductApi>()),
      child: const SearchScreen(),
    ),
  );

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<SearchBloc>().add(SearchSubmitted(_controller.text));

  void _clear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: _clear,
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => switch (state) {
          SearchIdle() => const MessageView(
            icon: Icons.search,
            text: 'Type a product name and press search.',
          ),
          SearchLoading() => const Center(child: CircularProgressIndicator()),
          SearchResults(:final products) => ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) => ProductTile(products[i]),
          ),
          SearchEmpty(:final query) => MessageView(
            icon: Icons.search_off,
            text: 'No products found for "$query".',
          ),
          SearchError(:final message) => MessageView(
            icon: Icons.cloud_off,
            text: message,
            onRetry: _submit,
          ),
        },
      ),
    );
  }
}
