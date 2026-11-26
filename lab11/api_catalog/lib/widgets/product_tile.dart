import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/details_screen.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {super.key});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.thumbnail,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.image_not_supported_outlined),
          ),
        ),
      ),
      title: Text(product.title),
      subtitle: Text(
        '\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}',
      ),
      onTap: () => Navigator.of(context).push(DetailsScreen.route(product.id)),
    );
  }
}
