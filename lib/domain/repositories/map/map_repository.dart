import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Репозиторий карты, который реализует функционал по расчету маршрутов и их
/// расстояний.
abstract class MapRepository {
  /// Функция для расчёта пути маршрута. Рассчитывается путь между точками
  /// маршрута [route].
  /// Использует всегда пеший вариант построения пути.
  Future<FutureResponse<MapRoute>> calculatePathForRoute(Route route);

  /// Функция для расчёта пути между двумя точками [start] и [dest].
  /// [type] указывается для указания алгоритма построения маршрута.
  Future<FutureResponse<MapRoute>> calculatePathBetweenPoints(
      LatLng start, LatLng dest, PathType type);

  /// Метод для расчёта длины пути
  double calculatePathLength(List<LatLng> points);
}

enum PathType { Walk, Car }
