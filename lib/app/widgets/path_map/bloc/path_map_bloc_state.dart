import 'package:city_go/data/repositories/map/map_repository_impl.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Состояние карты, которое содержит определенный набор данных, которые необходимы
/// карте.
class PathMapBlocState extends Equatable {
  /// Контроллер карты, с помощью которого идёт взаимодействие с картой
  /// Может быть null.
  final GoogleMapController? controller;

  /// Позиция пользователя на карте. Может быть равна null, если отключена геопозиция
  /// Если при получении позиции возникла ошибка, то она будет отображена в
  /// качестве уведомления пользователю.
  /// Может быть null.
  final FutureResponse<LatLng>? userPosition;

  /// Путь на карте, который отображается.
  /// Может быть null.
  final FutureResponse<MapRoute>? route;

  final PathType type;

  final bool isLocationSearching;

  PathMapBlocState({
    required this.type,
    this.controller,
    this.userPosition,
    this.route,
    this.isLocationSearching = false,
  });

  @override
  List<Object?> get props =>
      [controller?.mapId, userPosition, route, type, isLocationSearching];
}
