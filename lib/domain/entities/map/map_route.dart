import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Маршрут карты, который содержит путь и его расстояние.
/// Используется при рисовании маршрута на карте.
class MapRoute {
  /// Длина маршрута в метрах
  final double length;

  /// Координаты вершин пути, которые соединяются линиями
  final List<LatLng> coordinates;

  MapRoute(this.length, this.coordinates);
}
