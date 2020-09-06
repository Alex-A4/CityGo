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

  /// Позиция пользователя на карте. Может быть равна null, если отключена геопозиция
  /// Если при получении позиции возникла ошибка, то она будет отображена в
  /// качестве уведомления пользователю.
  /// Может быть null.
  final FutureResponse<LatLng> userPosition;

  final bool isLocationSearching;

  RouteMapBlocMapState({
    this.controller,
    this.route,
    this.userPosition,
    this.isLocationSearching = false,
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props =>
      [controller?.mapId, route, userPosition, isLocationSearching];
}
