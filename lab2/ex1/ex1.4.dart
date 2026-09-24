void main(List<String> argv){
    int sum = 0, count = 0;
    for(var x in argv){
        int? n = int.tryParse(x);
        if(n != null){
            sum += int.parse(x);
            count += 1;
        }
    }
    if(count == 0){
        print("You didn't provide any number");
        return;
    }
    print("The average of provided numbers is: ${1.0 * sum / count}");
}
