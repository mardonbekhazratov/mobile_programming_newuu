class Animal {
    final String name;
    Animal(this.name);

    void makeSound() => print("$name makes a sound");
}

class Dog extends Animal {
    Dog(super.name);

    @override
    void makeSound() => print("$name says: Woof!");

    void fetch() => print("$name brings the ball back");
}

void main(){
    List<Animal> animals = [Animal("Generic animal"), Dog("Rex")];
    for(Animal a in animals){
        a.makeSound();
    }
    Dog("Bobik").fetch();
}
