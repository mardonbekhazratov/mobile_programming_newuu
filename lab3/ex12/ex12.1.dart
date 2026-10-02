class InsufficientFundsException implements Exception {
    final double required;
    InsufficientFundsException(this.required);
    @override String toString() => "InsufficientFundsException: Missing \$$required";
}

void withdraw(double amount, double balance){
    if(amount > balance) throw InsufficientFundsException(amount - balance);
}

void main(){
    try{
        withdraw(150, 100);
    } on InsufficientFundsException catch(e){
        print("Caught custom exception: $e");
    } finally {
        print("Transaction complete.");
    }
}
