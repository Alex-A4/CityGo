import 'package:city_go/data/repositories/map/map_repository_impl.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Абстрактное событие для блока построения пути на карте
abstract class PathMapBlocEvent extends Equatable {}

/// Событие для инициализации блока и сохранения контроллера карты.
/// Также должна получать местоположение пользователя, если это возможно
class PathMapBlocInitEvent extends PathMapBlocEvent {
  final GoogleMapController controller;

  PathMapBlocInitEvent(this.controller);

  @override
  List<Object> get props => [];
}

/// Событие для изменения типа построения маршрута
class PathMapBlocChangeType extends PathMapBlocEvent {
  final PathType type;

  PathMapBlocChangeType(this.type);

  @override
  List<Object> get props => [type];
}

/// Событие для поиска позиции пользователя
class PathMapBlocFindLocation extends PathMapBlocEvent {
  @override
  List<Object> get props => [];
}
