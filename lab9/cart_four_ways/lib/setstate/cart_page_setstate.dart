import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';

class SetStateCartPage extends StatefulWidget {
  const SetStateCartPage({super.key});
  @override
  State<SetStateCartPage> createState() => _SetStateCartPageState();
}

class _SetStateCartPageState extends State<SetStateCartPage> {
  final _api = CheckoutApi();
  CartState _state = const CartState();
  final List<CartState> _history = [];

  void _update(CartState next) => setState(() {
        _history.add(_state);
        _state = next;
      });

  void _add(Product p) => _update(_state.copyWith(lines: _state.lines.withProduct(p)));
  void _changeQty(String id, int delta) => _update(_state.copyWith(lines: _state.lines.changeQty(id, delta)));
  void _applyCoupon(String code) => _update(_state.applyCoupon(code));
  void _undo() => setState(() => _state = _state.restore(_history.removeLast()));

  Future<void> _checkout() async {
    setState(() => _state = _state.copyWith(status: CheckoutStatus.submitting));
    CartState next;
    try {
      next = CartState(status: CheckoutStatus.success, orderId: await _api.submit(_state.total));
    } on CheckoutException catch (e) {
      next = _state.copyWith(status: CheckoutStatus.failure, checkoutError: e.message);
    }
    if (!mounted) return; // the page may have been popped during the await
    setState(() {
      if (next.status == CheckoutStatus.success) _history.clear();
      _state = next;
    });
    showCheckoutFeedback(context, next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Cart · setState'),
          actions: [IconButton(icon: const Icon(Icons.undo), onPressed: _history.isEmpty ? null : _undo)],
        ),
        body: CartBody(
          lines: _state.lines,
          onAdd: _add,
          onQtyChanged: _changeQty,
          couponError: _state.couponError,
          onApplyCoupon: _applyCoupon,
          summary: SummaryCard(_state.summary),
          submitting: _state.status == CheckoutStatus.submitting,
          onCheckout: _checkout,
        ),
      );
}
