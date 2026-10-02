abstract class PaymentProcessor { void process(double amount); }

class CreditCardProcessor implements PaymentProcessor {
    @override void process(double amount) => print("Paid \$$amount via Credit Card");
}

class CryptoProcessor implements PaymentProcessor {
    @override void process(double amount) => print("Paid \$$amount via Crypto Wallet");
}

void checkout(PaymentProcessor p, double amt) => p.process(amt);

void main(){
    List<PaymentProcessor> processors = [CreditCardProcessor(), CryptoProcessor()];
    for(PaymentProcessor p in processors){
        checkout(p, 49.99);
    }
}
