import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:equatable/equatable.dart';

/// Абстрактный класс состояния для блока списков маршрутов
abstract class RouteListBlocState extends Equatable {}

/// Состояние, которое отображает список маршрутов
class RouteListBlocDisplayState extends RouteListBlocState {
  /// Список маршрутов
  final List<RouteClipped> routes;

  /// Флаг означающий, что достигнут конец списка маршрутов и больше нечего грузить
  final bool isEndOfList;

  /// Код ошибки, полученной при загрузке, опционален.
  /// Если код ошибки не null, то [isEndOfList] должен быть true
  final String errorCode;

  RouteListBlocDisplayState(this.routes, this.isEndOfList, [this.errorCode])
      : assert(errorCode != null && isEndOfList || errorCode == null);

  @override
  List<Object> get props => [routes, isEndOfList, errorCode];
}

/// Состояние, которое отображает список маршрутов при условии, что также идёт
/// загрузка новых маршрутов.
class RouteListBlocLoadingState extends RouteListBlocState {
  /// Список маршрутов
  final List<RouteClipped> routes;

  RouteListBlocLoadingState(this.routes);

  @override
  List<Object> get props => [routes];
}
