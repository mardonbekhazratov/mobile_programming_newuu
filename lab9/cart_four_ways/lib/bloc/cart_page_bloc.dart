import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cart_page_cubit.dart';
import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';

class BlocCartPage extends StatelessWidget {
  const BlocCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CartBloc(CheckoutApi()),
        child: BlocListener<CartBloc, CartState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: showCheckoutFeedback,
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, s) {
              final bloc = context.read<CartBloc>();
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Cart · Bloc'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: s.canUndo ? () => bloc.add(const CartUndone()) : null,
                    ),
                  ],
                ),
                body: CartBody(
                  lines: s.lines,
                  onAdd: (p) => bloc.add(CartProductAdded(p)),
                  onQtyChanged: (id, delta) => bloc.add(CartQtyChanged(id, delta)),
                  couponError: s.couponError,
                  onApplyCoupon: (code) => bloc.add(CartCouponApplied(code)),
                  summary: const SelectedSummary<CartBloc>(),
                  submitting: s.status == CheckoutStatus.submitting,
                  onCheckout: () => bloc.add(const CartCheckoutRequested()),
                ),
              );
            },
          ),
        ),
      );
}
