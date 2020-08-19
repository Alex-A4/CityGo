import 'package:city_go/constants.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;

import 'distance_calculator.dart';

export 'package:city_go/domain/repositories/map/map_repository.dart';

/// Реализация репозитория карт, который позволяет строить маршруты между точками
class MapRepositoryImpl extends MapRepository {
  final PolylinePoints pathCreator;
  final NetworkChecker checker;
  final DistanceCalculator calculator;

  MapRepositoryImpl(this.pathCreator, this.checker, this.calculator);

  @override
  Future<FutureResponse<MapRoute>> calculatePathBetweenPoints(
      g.LatLng start, g.LatLng dest, PathType type) async {
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      final result = await pathCreator.getRouteBetweenCoordinates(
        MAP_API_KEY,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(dest.latitude, dest.longitude),
        travelMode: _convertMode(type),
      );
      if (result.points.isEmpty) throw UNEXPECTED_ERROR;

      final pathPoints = <g.LatLng>[];
      result.points
          .forEach((e) => pathPoints.add(g.LatLng(e.latitude, e.longitude)));

      return FutureResponse.success(
        MapRoute(calculatePathLength(pathPoints), pathPoints),
      );
    } catch (e) {
      return FutureResponse.fail(e);
    }
  }

  @override
  Future<FutureResponse<MapRoute>> calculatePathForRoute(Route route) async {
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      final pathPoints = <g.LatLng>[];
      final sorted = route.sortedPoints;

      /// TODO: Если будет занимать много времени, то сделать через Future.wait
      for (int i = 0; i < sorted.length - 1; i++) {
        final result = await pathCreator.getRouteBetweenCoordinates(
          MAP_API_KEY,
          PointLatLng(sorted[i].latitude, sorted[i].longitude),
          PointLatLng(sorted[i + 1].latitude, sorted[i + 1].longitude),
          travelMode: TravelMode.walking,
        );
        if (result.points.isEmpty) throw UNEXPECTED_ERROR;

        result.points
            .forEach((e) => pathPoints.add(g.LatLng(e.latitude, e.longitude)));
      }

      /// TODO: проверить, в тех ли единицах длина маршрута
      return FutureResponse.success(MapRoute(route.length, pathPoints));
    } catch (e) {
      return FutureResponse.fail(e);
    }
  }

  @override
  double calculatePathLength(List<g.LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculator.coordinateDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  /// Метод для конвертации внутреннего типа маршрута в режим плагина.
  TravelMode _convertMode(PathType type) {
    switch (type) {
      case PathType.Walk:
        return TravelMode.walking;
      case PathType.Car:
        return TravelMode.driving;
    }
    return null;
  }
}
