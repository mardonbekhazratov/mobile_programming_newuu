import 'package:bloc_test/bloc_test.dart';
import 'package:cart_four_ways/bloc/cart_bloc.dart';
import 'package:cart_four_ways/bloc/cart_event.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog.first;
  late MockCheckoutApi mockApi;
  setUp(() => mockApi = MockCheckoutApi());

  blocTest<CartBloc, CartState>(
    'add, add, SAVE10 emits three states',
    build: () => CartBloc(mockApi),
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(CartProductAdded(keyboard))
      ..add(const CartCouponApplied('SAVE10')),
    expect: () => [
      CartState(lines: [CartLine(product: keyboard, qty: 1)]),
      CartState(lines: [CartLine(product: keyboard, qty: 2)]),
      CartState(lines: [CartLine(product: keyboard, qty: 2)], coupon: 'SAVE10'),
    ],
  );

  blocTest<CartBloc, CartState>(
    'failed checkout emits submitting then failure',
    setUp: () => when(() => mockApi.submit(any())).thenThrow(const CheckoutException('Card declined')),
    build: () => CartBloc(mockApi),
    seed: () => CartState(lines: [CartLine(product: keyboard, qty: 1)]),
    act: (b) => b.add(const CartCheckoutRequested()),
    expect: () => [
      CartState(lines: [CartLine(product: keyboard, qty: 1)], status: CheckoutStatus.submitting),
      CartState(
        lines: [CartLine(product: keyboard, qty: 1)],
        status: CheckoutStatus.failure,
        checkoutError: 'Card declined',
      ),
    ],
  );

  blocTest<CartBloc, CartState>(
    'droppable: a second checkout while submitting is ignored',
    setUp: () => when(() => mockApi.submit(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return 'ORD-1';
    }),
    build: () => CartBloc(mockApi),
    act: (b) => b
      ..add(const CartCheckoutRequested())
      ..add(const CartCheckoutRequested()),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const CartState(status: CheckoutStatus.submitting),
      const CartState(status: CheckoutStatus.success, orderId: 'ORD-1'),
    ],
    verify: (_) => verify(() => mockApi.submit(any())).called(1),
  );
}
