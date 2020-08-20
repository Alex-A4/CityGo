import 'package:city_go/data/repositories/map/map_repository_impl.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

/// Абстрактное состояние для блока построения пути на карте
abstract class PathMapBlocState extends Equatable {}

/// Состояние карты, которое содержит определенный набор данных, которые необходимы
/// карте.
class PathMapBlocMapState extends PathMapBlocState {
  /// Контроллер карты, с помощью которого идёт взаимодействие с картой
  /// Может быть null.
  final GoogleMapController controller;

  /// Позиция пользователя на карте. Может быть равна null, если отключена геопозиция
  /// Если при получении позиции возникла ошибка, то она будет отображена в
  /// качестве уведомления пользователю.
  /// Может быть null.
  final FutureResponse<LatLng> userPosition;

  /// Путь на карте, который отображается.
  /// Может быть null.
  final FutureResponse<MapRoute> route;

  final PathType type;

  PathMapBlocMapState({
    @required this.type,
    this.controller,
    this.userPosition,
    this.route,
  });

  @override
  List<Object> get props => [controller?.mapId, userPosition, route, type];
}
