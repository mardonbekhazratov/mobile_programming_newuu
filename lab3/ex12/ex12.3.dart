String greet(String? name){
    if(name == null || name.trim().isEmpty){
        throw ArgumentError.value(name, "name", "must not be null or empty");
    }
    return "Hello, ${name.trim()}!";
}

void main(){
    for(String? input in ["Alice", "", "   ", null]){
        try{
            print(greet(input));
        } on ArgumentError catch(e){
            print("ArgumentError -> name: ${e.name}, value: '${e.invalidValue}', message: ${e.message}");
        }
    }
}
