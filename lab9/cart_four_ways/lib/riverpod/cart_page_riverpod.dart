import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../widgets/cart_body.dart';
import 'cart_notifier.dart';

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(cartProvider); // subscribe: rebuild on change
    final cart = ref.read(cartProvider.notifier); // method handles, no subscription
    ref.listen(cartProvider, (prev, next) => debugPrint('cartProvider: $prev -> $next'));
    ref.listen(cartProvider.select((s) => s.status), (_, _) => showCheckoutFeedback(context, ref.read(cartProvider)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart · Riverpod'),
        actions: [IconButton(icon: const Icon(Icons.undo), onPressed: ref.watch(canUndoProvider) ? cart.undo : null)],
      ),
      body: CartBody(
        lines: s.lines,
        onAdd: cart.add,
        onQtyChanged: cart.changeQty,
        couponError: s.couponError,
        onApplyCoupon: cart.applyCoupon,
        summary: const _Summary(),
        submitting: s.status == CheckoutStatus.submitting,
        onCheckout: cart.checkout,
      ),
    );
  }
}

/// Rebuilds only when one of the summary values changes, not on every cart change.
class _Summary extends ConsumerWidget {
  const _Summary();

  @override
  Widget build(BuildContext context, WidgetRef ref) => SummaryCard(ref.watch(cartProvider.select((s) => s.summary)));
}
