int divide(int a, int b){
    try{
        // Integer division by zero throws IntegerDivisionByZeroException,
        // which is a subtype of UnsupportedError.
        return a ~/ b;
    } on UnsupportedError catch(e){
        print("Can't divide $a by $b: $e");
        return 0;
    }
}

void main(){
    print("10 ~/ 3 = ${divide(10, 3)}");
    print("10 ~/ 0 = ${divide(10, 0)}");

    // Note: double division does NOT throw, it gives Infinity / NaN.
    print("10 / 0 = ${10 / 0}, 0 / 0 = ${0 / 0}");
}
