void main(List<String> argv){
    if(argv.length != 1){
        print("Provide 1 argument");
        return;
    }
    int? x = int.tryParse(argv[0]);
    if(x == null){
        print("Provide a number");
        return;
    }
    if(x > 0){
        print("positive");
    }
    else if(x < 0){
        print("negative");
    }
    else{
        print("zero");
    }
}
