import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:equatable/equatable.dart';

/// Абстрактное состояние со списком мест
abstract class VisitListBlocState extends Equatable {}

/// Состояние, которое отображает тип места и список загруженных мест.
/// Если данных нет, то содержит пустой список.
class VisitListBlocPlaceState extends VisitListBlocState {
  final PlaceType type;
  final List<ClippedVisitPlace> places;
  final String? errorCode;
  final bool isEndOfList;
  final PlaceSortType sortType;

  VisitListBlocPlaceState(
      this.type, this.places, this.sortType, this.isEndOfList,
      [this.errorCode]);

  @override
  List<Object?> get props => [type, places, errorCode, isEndOfList, sortType];
}

/// Состояние, которое отображает, что идёт процесс загрузки данных.
/// В состоянии указываются данные, которые были загружены ранее.
class VisitListBlocPlaceLoadingState extends VisitListBlocState {
  final PlaceType type;
  final List<ClippedVisitPlace> places;
  final PlaceSortType sortType;

  VisitListBlocPlaceLoadingState(this.type, this.places, this.sortType);

  @override
  List<Object> get props => [type, places, sortType];
}
