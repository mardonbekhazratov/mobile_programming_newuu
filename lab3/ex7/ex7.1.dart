enum Planet {
    mercury(mass: 3.3e23),
    venus(mass: 4.87e24),
    earth(mass: 5.97e24);

    final double mass;
    const Planet({required this.mass});
    bool get isHabitable => this == Planet.earth;
}

void main(){
    for(Planet p in Planet.values){
        print("${p.name}: mass=${p.mass} kg, habitable=${p.isHabitable}");
    }
}
