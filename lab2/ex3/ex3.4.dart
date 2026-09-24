import 'dart:math';
import 'dart:io';

void main(){
    int x = Random(42).nextInt(1000);
    while(true){
        print("Enter a number: ");
        int guess = int.parse(stdin.readLineSync() ?? "0");
        if(guess < x){
            print("try higher");
        }
        else if(guess > x){
            print("try lower");
        }
        else{
            print("good job");
            return;
        }
    }
}
