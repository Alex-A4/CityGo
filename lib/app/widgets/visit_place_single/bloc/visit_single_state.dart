import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:equatable/equatable.dart';

/// Абстрактное состояние блока для загрузки конкретного полного места
abstract class VisitSingleBlocState extends Equatable {}

/// Начальное состояние, которое инициализируется в момент создания, ничего
/// не содержит.
class VisitSingleBlocEmptyState extends VisitSingleBlocState {
  @override
  List<Object> get props => [];
}

/// Состояние, которое отображается после загрузки данных
class VisitSingleBlocDataState extends VisitSingleBlocState {
  final FullVisitPlace? place;
  final String? errorCode;

  VisitSingleBlocDataState(this.place, [this.errorCode]);

  @override
  List<Object?> get props => [place, errorCode];
}
