mixin Walker {
    void walk() => print("$runtimeType is walking");
}

mixin Swimmer {
    void swim() => print("$runtimeType is swimming");
}

mixin Flyable {
    void fly() => print("$runtimeType is flying");
}

class Animal {
    final String name;
    Animal(this.name);
}

class Duck extends Animal with Walker, Swimmer, Flyable {
    Duck(super.name);

    void dailyRoutine(){
        walk();
        swim();
        fly();
    }
}

class Penguin extends Animal with Walker, Swimmer {
    Penguin(super.name);
}

void main(){
    Duck d = Duck("Donald");
    d.dailyRoutine();

    Penguin p = Penguin("Pingu");
    p.walk();
    p.swim();

    List<Animal> zoo = [d, p];
    for(Animal a in zoo){
        // Animal is not a Flyable, so use a pattern to test and cast at once.
        if(a case Flyable flyer){
            flyer.fly();
        } else {
            print("${a.name} can't fly");
        }
    }
}
