import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:equatable/equatable.dart';

/// Абстрактное событие блока со списком мест
abstract class VisitListBlocEvent extends Equatable {}

/// Событие для загрузки мест с сервера
class VisitListBlocLoadPlacesEvent extends VisitListBlocEvent {
  @override
  List<Object> get props => [];
}

/// Событие для смены типа сортировки
class VisitListBlocChangeSortType extends VisitListBlocEvent {
  final PlaceSortType type;

  VisitListBlocChangeSortType(this.type);

  @override
  List<Object> get props => [type];
}
