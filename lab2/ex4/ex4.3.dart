String concat({String prefix = "", String suffix = ""}){
    return prefix + suffix;
}

void main(){
    print(concat(prefix: "try", suffix: " again"));
}
