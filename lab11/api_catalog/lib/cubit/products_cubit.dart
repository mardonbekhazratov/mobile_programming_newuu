import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._api) : super(const ProductsLoading());
  final ProductApi _api;
  bool _loadingMore = false;

  Future<void> load() async {
    emit(const ProductsLoading());
    try {
      final page = await _api.getProducts();
      if (isClosed) return;
      emit(ProductsLoaded(page.products, total: page.total));
    } on ApiException catch (e) {
      if (!isClosed) emit(ProductsError(e.message));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (_loadingMore || current is! ProductsLoaded || !current.hasMore) return;
    _loadingMore = true;
    try {
      final page = await _api.getProducts(skip: current.products.length);
      // Skip if the screen closed or a refresh replaced the list meanwhile.
      if (isClosed || state != current) return;
      emit(
        ProductsLoaded([
          ...current.products,
          ...page.products,
        ], total: page.total),
      );
    } on ApiException catch (e) {
      if (!isClosed && state == current) emit(ProductsError(e.message));
    } finally {
      _loadingMore = false;
    }
  }
}
