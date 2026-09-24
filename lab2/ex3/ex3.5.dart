void main(){
    int i = 0, s =0;
    while(true){
        i += 1;
        if(i == 10){
            break;
        }
        if(i == 5){
            continue;
        }
        s += i;
        print("$i: $s");
    }
}
