abstract class Entity {
    String get id;
}

class User implements Entity {
    @override
    final String id;
    final String name;
    User(this.id, this.name);

    @override
    String toString() => "User($id, $name)";
}

class Product implements Entity {
    @override
    final String id;
    final String title;
    final double price;
    Product(this.id, this.title, this.price);

    @override
    String toString() => "Product($id, $title, \$$price)";
}

// One generic class works for every Entity type.
class Repository<T extends Entity> {
    final Map<String, T> _items = {};

    void save(T item) => _items[item.id] = item;

    T? findById(String id) => _items[id];

    List<T> findAll() => _items.values.toList();

    List<T> where(bool Function(T item) test) => _items.values.where(test).toList();

    bool delete(String id) => _items.remove(id) != null;

    int get count => _items.length;
}

void main(){
    Repository<User> users = Repository<User>();
    users.save(User("u1", "Alice"));
    users.save(User("u2", "Bob"));

    Repository<Product> products = Repository<Product>();
    products.save(Product("p1", "Laptop", 1200));
    products.save(Product("p2", "Mouse", 25));
    products.save(Product("p3", "Monitor", 300));

    // users.save(Product("p4", "Pen", 1));  // compile error: wrong type

    print(users.findById("u2"));
    print(users.findAll());
    print(products.where((p) => p.price > 100));
    products.delete("p2");
    print("products left: ${products.count}");
}
