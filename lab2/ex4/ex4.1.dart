double calculateTotal ( double price , { double discount = 0.0 , double tax = 0.08}) {
    double discounted = price * (1 - discount );
    return discounted * (1 + tax);
}

void main () {
    print ('Total : \$${ calculateTotal (100.0 , discount : 0.15) . toStringAsFixed (2)}');
}
