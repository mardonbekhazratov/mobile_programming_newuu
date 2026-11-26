import '../models/product.dart';

sealed class DetailsState {
  const DetailsState();
}

final class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

final class DetailsError extends DetailsState {
  const DetailsError(this.message);
  final String message;
}

final class DetailsLoaded extends DetailsState {
  const DetailsLoaded(this.product);
  final Product product;
}
