/// Represents a bank account balance.
///
/// Throws an [ArgumentError] if [initialDeposit] is negative.
class BankAccount {
    double balance;
    BankAccount(double initialDeposit) : balance = initialDeposit {
        if (initialDeposit < 0) throw ArgumentError("Deposit cannot be negative");
    }
}

void main(){
    BankAccount account = BankAccount(250.0);
    print("Balance: ${account.balance}");

    try{
        BankAccount(-10);
    } on ArgumentError catch(e){
        print("Error: ${e.message}");
    }
}
