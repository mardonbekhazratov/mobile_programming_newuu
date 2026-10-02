Future<String> fetchUser() async {
    await Future.delayed(const Duration(seconds: 1));
    return "User #1024";
}

Stream<int> countStream(int max) async* {
    for(int i = 1; i <= max; i++){
        await Future.delayed(const Duration(milliseconds: 200));
        yield i;
    }
}

Future<void> main() async {
    print("Fetching user...");
    String user = await fetchUser();
    print("Got $user");

    await for(int n in countStream(5)){
        print("count: $n");
    }
    print("Stream finished");
}
