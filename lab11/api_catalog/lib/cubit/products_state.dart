import '../models/product.dart';

sealed class ProductsState {
  const ProductsState();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);
  final String message;
}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded(this.products, {required this.total});
  final List<Product> products;
  final int total;
  bool get hasMore => products.length < total;
}
