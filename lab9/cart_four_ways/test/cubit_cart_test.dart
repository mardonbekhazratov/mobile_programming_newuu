import 'package:bloc_test/bloc_test.dart';
import 'package:cart_four_ways/cubit/cart_cubit.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog.first;
  late MockCheckoutApi mockApi;
  setUp(() => mockApi = MockCheckoutApi());

  blocTest<CartCubit, CartState>(
    'add, add, SAVE10 emits three states',
    build: () => CartCubit(mockApi),
    act: (c) {
      c.add(keyboard);
      c.add(keyboard);
      c.applyCoupon('SAVE10');
    },
    expect: () => [
      CartState(lines: [CartLine(product: keyboard, qty: 1)]),
      CartState(lines: [CartLine(product: keyboard, qty: 2)]),
      CartState(lines: [CartLine(product: keyboard, qty: 2)], coupon: 'SAVE10'),
    ],
  );

  blocTest<CartCubit, CartState>(
    'failed checkout emits submitting then failure',
    setUp: () => when(() => mockApi.submit(any())).thenThrow(const CheckoutException('Card declined')),
    build: () => CartCubit(mockApi),
    seed: () => CartState(lines: [CartLine(product: keyboard, qty: 1)]),
    act: (c) => c.checkout(),
    expect: () => [
      CartState(lines: [CartLine(product: keyboard, qty: 1)], status: CheckoutStatus.submitting),
      CartState(
        lines: [CartLine(product: keyboard, qty: 1)],
        status: CheckoutStatus.failure,
        checkoutError: 'Card declined',
      ),
    ],
  );
}
