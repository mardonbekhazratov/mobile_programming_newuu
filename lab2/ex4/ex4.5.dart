int fib(int n){
    if(n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

void main(){
    int n = 7;
    print("${n}th fibonacci number is ${fib(7)}");
}
