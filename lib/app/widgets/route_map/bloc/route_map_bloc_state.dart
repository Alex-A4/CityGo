import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RouteMapBlocState extends Equatable {}

/// Состояние карты, которое содержит определенный набор данных, которые необходимы
/// карте.
class RouteMapBlocMapState extends RouteMapBlocState {
  /// Контроллер карты, с помощью которого идёт взаимодействие с картой
  /// Может быть null.
  final GoogleMapController controller;

  /// Путь на карте, который отображается.
  /// Может быть null.
  final FutureResponse<MapRoute> route;

  RouteMapBlocMapState({
    this.controller,
    this.route,
  });


  @override
  List<Object> get props => [controller?.mapId, route];
}
