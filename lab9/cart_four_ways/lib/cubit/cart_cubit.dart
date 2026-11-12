import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._api) : super(const CartState());
  final CheckoutApi _api;

  void _update(CartState next) => emit(state.push(next)); // dropped by Cubit if next == state

  void add(Product p) => _update(state.copyWith(lines: state.lines.withProduct(p)));
  void remove(String id) => _update(state.copyWith(lines: state.lines.without(id)));
  void changeQty(String id, int delta) => _update(state.copyWith(lines: state.lines.changeQty(id, delta)));
  void applyCoupon(String code) => _update(state.applyCoupon(code));

  void undo() {
    if (state.canUndo) emit(state.pop());
  }

  Future<void> checkout() async {
    emit(state.copyWith(status: CheckoutStatus.submitting));
    try {
      final orderId = await _api.submit(state.total);
      if (isClosed) return; // the page was popped during the await
      emit(CartState(status: CheckoutStatus.success, orderId: orderId));
    } on CheckoutException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: CheckoutStatus.failure, checkoutError: e.message));
    }
  }

  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
    debugPrint('CartCubit ${change.currentState} -> ${change.nextState}');
  }
}
