/// A simple **temperature converter**.
///
/// Supported conversions:
/// * Celsius -> Fahrenheit
/// * Fahrenheit -> Celsius
/// * Celsius -> Kelvin
///
/// **Note:** temperatures below *absolute zero* (-273.15 C) are rejected.
///
/// Example:
/// ```dart
/// var converter = TemperatureConverter();
/// print(converter.celsiusToFahrenheit(100)); // 212.0
/// ```
///
/// See also [celsiusToKelvin] for scientific use.
class TemperatureConverter {
    /// Lowest possible temperature in Celsius.
    static const double absoluteZero = -273.15;

    /// Converts [celsius] to Fahrenheit.
    ///
    /// Formula: **F = C * 9 / 5 + 32**
    ///
    /// ```dart
    /// converter.celsiusToFahrenheit(0); // 32.0
    /// ```
    double celsiusToFahrenheit(double celsius){
        _check(celsius);
        return celsius * 9 / 5 + 32;
    }

    /// Converts [fahrenheit] to Celsius.
    ///
    /// Formula: **C = (F - 32) * 5 / 9**
    double fahrenheitToCelsius(double fahrenheit){
        double celsius = (fahrenheit - 32) * 5 / 9;
        _check(celsius);
        return celsius;
    }

    /// Converts [celsius] to Kelvin.
    ///
    /// * **0 C** is `273.15 K`
    /// * **-273.15 C** is `0 K`
    double celsiusToKelvin(double celsius){
        _check(celsius);
        return celsius - absoluteZero;
    }

    void _check(double celsius){
        if(celsius < absoluteZero){
            throw ArgumentError("$celsius C is below absolute zero");
        }
    }
}

void main(){
    var converter = TemperatureConverter();
    print(converter.celsiusToFahrenheit(100));
    print(converter.fahrenheitToCelsius(32));
    print(converter.celsiusToKelvin(0));
}
