enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

void main(){
    for(Day d in Day.values){
        bool weekend = d == Day.saturday || d == Day.sunday;
        print("${d.index + 1}. ${d.name}${weekend ? " (weekend)" : ""}");
    }
    print("Total days: ${Day.values.length}");
}
