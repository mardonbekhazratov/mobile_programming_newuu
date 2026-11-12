import 'package:flutter/material.dart';
import '../models/cart.dart';

class CartBody extends StatelessWidget {
  const CartBody({
    super.key,
    required this.lines,
    required this.onAdd,
    required this.onQtyChanged,
    required this.couponError,
    required this.onApplyCoupon,
    required this.summary,
    required this.submitting,
    required this.onCheckout,
  });
  final List<CartLine> lines;
  final void Function(Product) onAdd;
  final void Function(String productId, int delta) onQtyChanged;
  final String? couponError;
  final void Function(String code) onApplyCoupon;
  final Widget summary;
  final bool submitting;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(spacing: 8, children: [
            for (final p in catalog)
              ActionChip(label: Text('${p.name} · ${p.price.toStringAsFixed(0)}'), onPressed: () => onAdd(p)),
          ]),
        ),
        Expanded(
          child: lines.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView(children: [
                  for (final l in lines)
                    ListTile(
                      key: ValueKey(l.product.id),
                      title: Text(l.product.name),
                      subtitle: Text('× ${l.qty}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: () => onQtyChanged(l.product.id, -1)),
                        IconButton(icon: const Icon(Icons.add), onPressed: () => onQtyChanged(l.product.id, 1)),
                      ]),
                    ),
                ]),
        ),
        CouponField(error: couponError, onApply: onApplyCoupon),
        summary,
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: lines.isEmpty ? null : onCheckout,
            icon: submitting
                ? SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                  )
                : const Icon(Icons.shopping_cart_checkout),
            label: const Text('Checkout'),
          ),
        ),
      ]);
}

class CouponField extends StatefulWidget {
  const CouponField({super.key, required this.error, required this.onApply});
  final String? error;
  final void Function(String code) onApply;

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Coupon',
            errorText: widget.error,
            suffixIcon: TextButton(onPressed: () => widget.onApply(_controller.text), child: const Text('Apply')),
          ),
        ),
      );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard(this.summary, {super.key});
  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    debugPrint('SummaryCard build: total ${summary.total.toStringAsFixed(2)}');
    Widget row(String label, String value) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value)]);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          row('Items', '${summary.items}'),
          row('Subtotal', summary.subtotal.toStringAsFixed(2)),
          row('Discount', summary.discount.toStringAsFixed(2)),
          row('Total', summary.total.toStringAsFixed(2)),
        ]),
      ),
    );
  }
}

/// Shows the SnackBar (success) or MaterialBanner (failure) for a checkout result.
void showCheckoutFeedback(BuildContext context, CartState s) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentMaterialBanner();
  switch (s.status) {
    case CheckoutStatus.success:
      messenger.showSnackBar(SnackBar(content: Text('Order ${s.orderId} placed')));
    case CheckoutStatus.failure:
      messenger.showMaterialBanner(MaterialBanner(
        content: Text('Checkout failed: ${s.checkoutError}'),
        actions: [TextButton(onPressed: messenger.hideCurrentMaterialBanner, child: const Text('Dismiss'))],
      ));
    case CheckoutStatus.idle || CheckoutStatus.submitting:
      break;
  }
}
