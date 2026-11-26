import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/message_view.dart';
import '../widgets/product_tile.dart';
import 'search_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).push(SearchScreen.route()),
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) => switch (state) {
          ProductsLoading() => const Center(child: CircularProgressIndicator()),
          ProductsError(:final message) => MessageView(
            icon: Icons.cloud_off,
            text: message,
            onRetry: cubit.load,
          ),
          ProductsLoaded(:final products, :final total, :final hasMore) =>
            RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView.builder(
                itemCount: products.length + (hasMore ? 1 : 0),
                itemBuilder: (_, i) => i < products.length
                    ? ProductTile(products[i])
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton(
                          onPressed: cubit.loadMore,
                          child: Text(
                            'Load more (${products.length} of $total)',
                          ),
                        ),
                      ),
              ),
            ),
        },
      ),
    );
  }
}
