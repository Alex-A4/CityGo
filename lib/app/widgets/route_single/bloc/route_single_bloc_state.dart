import 'package:city_go/domain/entities/routes/route.dart';
import 'package:equatable/equatable.dart';

/// Абстрактное состояние для блока конкретных маршрутов
abstract class RouteSingleBlocState extends Equatable {}

/// Начальное состояние, которое инициализируется в момент создания, ничего
/// не содержит.
class RouteSingleBlocEmptyState extends RouteSingleBlocState {
  @override
  List<Object> get props => [];
}

/// Состояние, которое отображается после загрузки данных
class RouteSingleBlocDataState extends RouteSingleBlocState {
  final Route? route;
  final String? errorCode;

  RouteSingleBlocDataState(this.route, [this.errorCode]);

  @override
  List<Object> get props => [];
}
