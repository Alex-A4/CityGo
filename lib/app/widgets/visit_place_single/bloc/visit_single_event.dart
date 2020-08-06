import 'package:equatable/equatable.dart';

/// Абстрактное событие блока для загрузки конкретного полного места
abstract class VisitSingleBlocEvent extends Equatable {}

/// Событие для загрузки данных
class VisitSingleBlocLoadEvent extends VisitSingleBlocEvent {
  @override
  List<Object> get props => [];
}
