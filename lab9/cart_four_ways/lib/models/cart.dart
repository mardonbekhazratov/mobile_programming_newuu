class Product {
  const Product({required this.id, required this.name, required this.price});
  final String id;
  final String name;
  final double price;
}

const catalog = [
  Product(id: 'p1', name: 'Keyboard', price: 49),
  Product(id: 'p2', name: 'Mouse', price: 25),
  Product(id: 'p3', name: 'Monitor', price: 199),
];

class CartLine {
  const CartLine({required this.product, required this.qty});
  final Product product;
  final int qty;
  double get subtotal => product.price * qty;
  CartLine copyWith({int? qty}) => CartLine(product: product, qty: qty ?? this.qty);
}

/// Pure, style-independent cart logic. Every state holder calls these.
extension CartLines on List<CartLine> {
  List<CartLine> withProduct(Product p) {
    final i = indexWhere((l) => l.product.id == p.id);
    if (i == -1) return [...this, CartLine(product: p, qty: 1)];
    return [for (final l in this) l.product.id == p.id ? l.copyWith(qty: l.qty + 1) : l];
  }

  List<CartLine> without(String productId) =>
      [for (final l in this) if (l.product.id != productId) l];

  /// Adds [delta] to the line's qty; a line that reaches 0 is removed.
  List<CartLine> changeQty(String productId, int delta) => [
        for (final l in this)
          if (l.product.id != productId)
            l
          else if (l.qty + delta > 0)
            l.copyWith(qty: l.qty + delta),
      ];

  double get subtotal => fold(0, (s, l) => s + l.subtotal);
  int get itemCount => fold(0, (s, l) => s + l.qty);
}

enum CheckoutStatus { idle, submitting, success, failure }

typedef CartSummary = ({int items, double subtotal, double discount, double total});

const _keep = Object(); // copyWith sentinel, so nullable fields can be set to null

class CartState {
  const CartState({
    this.lines = const [],
    this.coupon,
    this.couponError,
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.checkoutError,
  });

  final List<CartLine> lines;
  final String? coupon;
  final String? couponError;
  final CheckoutStatus status;
  final String? orderId;
  final String? checkoutError;

  // Derived values: always computed, never stored.
  int get itemCount => lines.itemCount;
  double get subtotal => lines.subtotal;
  double get discount => coupon == null ? 0 : subtotal * 0.1;
  double get total => subtotal - discount;
  CartSummary get summary => (items: itemCount, subtotal: subtotal, discount: discount, total: total);

  CartState copyWith({
    List<CartLine>? lines,
    Object? coupon = _keep,
    Object? couponError = _keep,
    CheckoutStatus? status,
    Object? orderId = _keep,
    Object? checkoutError = _keep,
  }) =>
      CartState(
        lines: lines ?? this.lines,
        coupon: coupon == _keep ? this.coupon : coupon as String?,
        couponError: couponError == _keep ? this.couponError : couponError as String?,
        status: status ?? this.status,
        orderId: orderId == _keep ? this.orderId : orderId as String?,
        checkoutError: checkoutError == _keep ? this.checkoutError : checkoutError as String?,
      );

  CartState applyCoupon(String code) => code.trim() == 'SAVE10'
      ? copyWith(coupon: 'SAVE10', couponError: null)
      : copyWith(coupon: null, couponError: 'Invalid coupon');

  /// Undo: the cart contents of [previous], but the checkout fields of now
  /// (so undo never brings back a stale "submitting" spinner).
  CartState restore(CartState previous) =>
      copyWith(lines: previous.lines, coupon: previous.coupon, couponError: previous.couponError);
}
