class ValidationException implements Exception {
    final String field;
    ValidationException(this.field);
    @override
    String toString() => "ValidationException: invalid $field";
}

void process(String input){
    switch(input){
        case "number": int.parse("12a");
        case "index": [1, 2, 3][10];
        case "custom": throw ValidationException("email");
        case "state": throw StateError("Not ready");
        case "string": throw "a plain string was thrown";
        default: print("'$input' processed OK");
    }
}

void main(){
    for(String input in ["ok", "number", "index", "custom", "state", "string"]){
        try{
            process(input);
        } on FormatException catch(e){
            print("Bad number format: ${e.source}");
        } on RangeError catch(e){
            print("Index problem: $e");
        } on ValidationException catch(e){
            print("Please fix the '${e.field}' field");
        } on Exception catch(e){
            print("Other Exception: $e");
        } catch(e){
            // Catches everything else: Errors and non-Exception objects.
            print("Unknown error (${e.runtimeType}): $e");
        }
    }
}
