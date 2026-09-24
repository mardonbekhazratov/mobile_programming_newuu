List<int> transformList(
    List<int> numbers,
    int Function(int) transformer
){
    List<int> result = [];
    for(int x in numbers){
        result.add(transformer(x));
    }
    return result;
}

