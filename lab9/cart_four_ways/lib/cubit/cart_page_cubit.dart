import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import 'cart_cubit.dart';

class CubitCartPage extends StatelessWidget {
  const CubitCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CartCubit(CheckoutApi()),
        child: BlocListener<CartCubit, CartState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: showCheckoutFeedback,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, s) {
              final cart = context.read<CartCubit>();
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Cart · Cubit'),
                  actions: [IconButton(icon: const Icon(Icons.undo), onPressed: s.canUndo ? cart.undo : null)],
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
            },
          ),
        ),
      );
}

/// Rebuilds only when one of the summary values changes.
class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) => BlocSelector<CartCubit, CartState, CartSummary>(
        selector: (s) => s.summary,
        builder: (_, summary) => SummaryCard(summary),
      );
}
