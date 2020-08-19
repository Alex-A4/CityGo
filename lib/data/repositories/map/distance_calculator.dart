import 'dart:math' show cos, sqrt, asin;

/// Класс для расчёта расстояния между двумя точками.
abstract class DistanceCalculator {
  /// Расчёт расстояния между двумя точками: [lat1, lon1] и [lat2, lon2]
  double coordinateDistance(lat1, lon1, lat2, lon2);
}

class DistanceCalculatorImpl extends DistanceCalculator {
  /// Расчёт расстояния между двумя точками: [lat1, lon1] и [lat2, lon2]
  /// Взята с: https://blog.codemagic.io/creating-a-route-calculator-using-google-maps/
  @override
  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
