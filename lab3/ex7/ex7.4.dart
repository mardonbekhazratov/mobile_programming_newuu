abstract interface class Discount {
    String get label;
    double apply(double price);
}

enum MembershipTier implements Discount {
    basic(rate: 0.0, freeShippingFrom: 100),
    silver(rate: 0.05, freeShippingFrom: 50),
    gold(rate: 0.10, freeShippingFrom: 20),
    platinum(rate: 0.20, freeShippingFrom: 0);

    final double rate;
    final double freeShippingFrom;

    const MembershipTier({required this.rate, required this.freeShippingFrom});

    @override
    String get label => "${name[0].toUpperCase()}${name.substring(1)} (${(rate * 100).round()}% off)";

    @override
    double apply(double price) => price * (1 - rate);

    double shippingCost(double price, {double fee = 5}) =>
        price >= freeShippingFrom ? 0 : fee;

    double total(double price) {
        double discounted = apply(price);
        return discounted + shippingCost(discounted);
    }

    MembershipTier? get nextTier =>
        index + 1 < values.length ? values[index + 1] : null;
}

void printReceipt(Discount d, double price){
    print("${d.label}: ${price.toStringAsFixed(2)} -> ${d.apply(price).toStringAsFixed(2)}");
}

void main(){
    double price = 40;
    for(MembershipTier tier in MembershipTier.values){
        printReceipt(tier, price);
        print("   total with shipping: ${tier.total(price).toStringAsFixed(2)}, "
            "next tier: ${tier.nextTier?.name ?? "none"}");
    }
}
