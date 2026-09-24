void main(List<String> argv){
    if(argv.length != 1){
        print("Provide 1 argument");
        return;
    }
    int? n = int.tryParse(argv[0]);
    if(n == null){
        print("Provide a number");
        return;
    }
    int factorial = 1;
    for(var i = 1; i <= n; i ++){
        factorial *= i;
    }
    print("for range: $factorial");
    List l = List.generate(n, (index) => index + 1);
    factorial = 1;
    for(int x in l){
        factorial *= x;
    }
    print("for-in with a list: $factorial");
}
