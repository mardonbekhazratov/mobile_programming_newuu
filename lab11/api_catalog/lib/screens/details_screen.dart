import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';
import '../cubit/details_state.dart';
import '../data/product_api.dart';
import '../models/product.dart';
import '../widgets/message_view.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  static Route<void> route(int id) => MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (c) => DetailsCubit(c.read<ProductApi>(), id)..load(),
      child: const DetailsScreen(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: BlocBuilder<DetailsCubit, DetailsState>(
        builder: (context, state) => switch (state) {
          DetailsLoading() => const Center(child: CircularProgressIndicator()),
          DetailsError(:final message) => MessageView(
            icon: Icons.cloud_off,
            text: message,
            onRetry: context.read<DetailsCubit>().load,
          ),
          DetailsLoaded(:final product) => _Details(product),
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final d = product.dimensions;
    final dates = MaterialLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 240,
          child: PageView(
            children: [
              for (final url in product.images)
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported_outlined, size: 48),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(product.title, style: text.titleLarge),
        Text(
          '\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 12),
        Text(product.description),
        const SizedBox(height: 12),
        Text('Dimensions: ${d.width} × ${d.height} × ${d.depth}'),
        const SizedBox(height: 24),
        Text('Reviews (${product.reviews.length})', style: text.titleMedium),
        for (final r in product.reviews)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${'★' * r.rating}${'☆' * (5 - r.rating)}  ${r.reviewerName}',
            ),
            subtitle: Text('${dates.formatMediumDate(r.date)}\n${r.comment}'),
          ),
      ],
    );
  }
}
