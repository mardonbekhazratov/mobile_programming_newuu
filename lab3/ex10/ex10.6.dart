abstract interface class ShippingStrategy {
    String get name;
    double cost(double weightKg, double orderTotal);
}

class StandardShipping implements ShippingStrategy {
    @override
    String get name => "Standard";

    @override
    double cost(double weightKg, double orderTotal) => 5 + weightKg * 1.5;
}

class ExpressShipping implements ShippingStrategy {
    @override
    String get name => "Express";

    @override
    double cost(double weightKg, double orderTotal) => 15 + weightKg * 3;
}

class FreeOverThreshold implements ShippingStrategy {
    final double threshold;
    final ShippingStrategy fallback;
    FreeOverThreshold(this.threshold, this.fallback);

    @override
    String get name => "Free over \$$threshold (else ${fallback.name})";

    @override
    double cost(double weightKg, double orderTotal) =>
        orderTotal >= threshold ? 0 : fallback.cost(weightKg, orderTotal);
}

// The context: it doesn't know how the cost is calculated,
// it only delegates to whatever strategy it was given.
class Order {
    final double total;
    final double weightKg;
    ShippingStrategy shipping;

    Order(this.total, this.weightKg, this.shipping);

    double get shippingCost => shipping.cost(weightKg, total);
    double get grandTotal => total + shippingCost;

    void printSummary(){
        print("${shipping.name.padRight(32)} shipping: \$${shippingCost.toStringAsFixed(2)}"
            "  total: \$${grandTotal.toStringAsFixed(2)}");
    }
}

void main(){
    Order order = Order(80, 2, StandardShipping());
    order.printSummary();

    // Swap the behaviour at runtime without changing Order.
    order.shipping = ExpressShipping();
    order.printSummary();

    order.shipping = FreeOverThreshold(50, StandardShipping());
    order.printSummary();

    Order small = Order(30, 1, FreeOverThreshold(50, StandardShipping()));
    small.printSummary();
}
