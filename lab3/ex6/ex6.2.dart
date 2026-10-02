class Person {
    String name;
    int age;

    Person(this.name, this.age);

    void introduce(){
        print("Hi, I am $name and I am $age years old.");
    }
}

void main(){
    Person p = Person("Alice", 20);
    p.introduce();

    p.age += 1;
    p.introduce();
}
