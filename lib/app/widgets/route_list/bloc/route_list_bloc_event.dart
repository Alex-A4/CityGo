import 'package:equatable/equatable.dart';

/// Абстрактный класс события для блока списков маршрутов
abstract class RouteListBlocEvent extends Equatable {}

/// Событие для загрузки списка маршрутов
class RouteListDownloadEvent extends RouteListBlocEvent {
  @override
  List<Object> get props => [];
}
