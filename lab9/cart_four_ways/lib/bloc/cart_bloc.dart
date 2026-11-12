import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';
import 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._api) : super(const CartState()) {
    on<CartProductAdded>((e, emit) => _emit(e, emit, state.copyWith(lines: state.lines.withProduct(e.product))));
    on<CartProductRemoved>((e, emit) => _emit(e, emit, state.copyWith(lines: state.lines.without(e.productId))));
    on<CartQtyChanged>((e, emit) => _emit(e, emit, state.copyWith(lines: state.lines.changeQty(e.productId, e.delta))));
    on<CartCouponApplied>((e, emit) => _emit(e, emit, state.applyCoupon(e.code)));
    on<CartUndone>((e, emit) {
      if (state.canUndo) _emit(e, emit, state.pop());
    });
    on<CartCheckoutRequested>(_onCheckout, transformer: droppable());
  }

  final CheckoutApi _api;

  /// Which events go into the undo history. Exhaustive: a new event does not compile until
  /// it is listed here.
  static bool isUndoable(CartEvent event) => switch (event) {
        CartProductAdded() || CartProductRemoved() || CartQtyChanged() || CartCouponApplied() => true,
        CartCheckoutRequested() || CartUndone() => false,
      };

  void _emit(CartEvent event, Emitter<CartState> emit, CartState next) =>
      emit(isUndoable(event) ? state.push(next) : next);

  Future<void> _onCheckout(CartCheckoutRequested e, Emitter<CartState> emit) async {
    _emit(e, emit, state.copyWith(status: CheckoutStatus.submitting));
    try {
      final orderId = await _api.submit(state.total);
      if (emit.isDone) return; // the bloc was closed during the await
      _emit(e, emit, CartState(status: CheckoutStatus.success, orderId: orderId));
    } on CheckoutException catch (err) {
      if (emit.isDone) return;
      _emit(e, emit, state.copyWith(status: CheckoutStatus.failure, checkoutError: err.message));
    }
  }
}
