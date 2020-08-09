import 'package:equatable/equatable.dart';

/// Абстрактное событие для блока конкретных маршрутов
abstract class RouteSingleBlocEvent extends Equatable {}

/// Событие для загрузки информации о маршруте
class RouteSingleBlocLoadEvent extends RouteSingleBlocEvent {
  @override
  List<Object> get props => [];
}
