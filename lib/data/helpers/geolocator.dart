import 'package:city_go/data/core/localization_constants.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:google_maps_flutter/google_maps_flutter.dart';
export 'package:geolocator/geolocator.dart';

/// Поскольку плагин геолокатор ушел от использования класса в сторону методов,
/// то реализован свой класс с теми же функциями.
abstract class Geolocator {
  Future<bool> isLocationServiceEnabled();

  Future<g.Position> getCurrentPosition();

  Future<g.LocationPermission> requestPermission();

  /// Получение активной позиции с помощью [isLocationServiceEnabled] и
  /// [getCurrentPosition].
  /// Если возникают пробелмы, выбрасывает ошибку.
  Future<LatLng> getPosition();
}

/// Геолокатор просто перенаправляет вызов на функции плагина
class GeolocatorImpl extends Geolocator {
  @override
  Future<g.Position> getCurrentPosition() =>
      g.Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 3));

  @override
  Future<bool> isLocationServiceEnabled() =>
      g.Geolocator.isLocationServiceEnabled();

  @override
  Future<g.LocationPermission> requestPermission() =>
      g.Geolocator.requestPermission();

  @override
  Future<LatLng> getPosition() async {
    try {
      bool isEnabled = await isLocationServiceEnabled();
      if (isEnabled) {
        var position = await getCurrentPosition();
        return LatLng(position.latitude, position.longitude);
      } else
        throw LOCATION_SERVICE_DISABLED;
    } on String catch (e) {
      throw e;
    } catch (_) {
      throw LOCATION_ACCESS_DENIED;
    }
  }
}
