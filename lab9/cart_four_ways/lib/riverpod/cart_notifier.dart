import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';

final checkoutApiProvider = Provider((ref) => CheckoutApi());

class CartNotifier extends Notifier<CartState> {
  final _history = <CartState>[];

  @override
  CartState build() => const CartState();

  bool get canUndo => _history.isNotEmpty;

  void _update(CartState next) {
    if (next != state) _history.add(state); // only real changes are undoable
    state = next; // Riverpod does not notify when next == state
  }

  void add(Product p) => _update(state.copyWith(lines: state.lines.withProduct(p)));
  void remove(String id) => _update(state.copyWith(lines: state.lines.without(id)));
  void changeQty(String id, int delta) => _update(state.copyWith(lines: state.lines.changeQty(id, delta)));
  void applyCoupon(String code) => _update(state.applyCoupon(code));

  void undo() {
    if (_history.isNotEmpty) state = state.restore(_history.removeLast());
  }

  Future<void> checkout() async {
    final api = ref.read(checkoutApiProvider);
    state = state.copyWith(status: CheckoutStatus.submitting);
    try {
      final orderId = await api.submit(state.total);
      _history.clear();
      state = CartState(status: CheckoutStatus.success, orderId: orderId);
    } on CheckoutException catch (e) {
      state = state.copyWith(status: CheckoutStatus.failure, checkoutError: e.message);
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

final canUndoProvider = Provider<bool>((ref) {
  ref.watch(cartProvider); // the history only changes together with the cart
  return ref.watch(cartProvider.notifier).canUndo;
});
