import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RouteMapBlocEvent extends Equatable {}

/// Событие для инициализации блока и сохранения контроллера карты.
/// Также должна получать местоположение пользователя, если это возможно
class RouteMapBlocInitEvent extends RouteMapBlocEvent {
  final GoogleMapController controller;

  RouteMapBlocInitEvent(this.controller);

  @override
  List<Object> get props => [];
}

/// Событие для поиска позиции пользователя
class RouteMapBlocFindLocation extends RouteMapBlocEvent {
  @override
  List<Object> get props => [];
}

/// Событие для обновления пути, если этого не было сделано
class RouteMapBlocUpdatePath extends RouteMapBlocEvent {
  @override
  List<Object> get props => [];
}
