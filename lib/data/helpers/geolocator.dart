import 'package:geolocator/geolocator.dart' as g;

/// Поскольку плагин геолокатор ушел от использования класса в сторону методов,
/// то реализован свой класс с теми же функциями.
abstract class Geolocator {
  Future<bool> isLocationServiceEnabled();

  Future<g.Position> getCurrentPosition();

  Future<g.LocationPermission> requestPermission();
}

/// Геолокатор просто перенаправляет вызов на функции плагина
class GeolocatorImpl extends Geolocator {
  @override
  Future<g.Position> getCurrentPosition() => g.getCurrentPosition();

  @override
  Future<bool> isLocationServiceEnabled() => g.isLocationServiceEnabled();

  @override
  Future<g.LocationPermission> requestPermission() => g.requestPermission();
}
