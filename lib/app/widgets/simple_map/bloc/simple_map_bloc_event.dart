import 'package:city_go/data/repositories/profile/user_remote_repo_impl.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Событие для простой карты
abstract class SimpleMapBlocEvent extends Equatable {}

/// Событие для инициализации блока и сохранения контроллера карты.
/// Также должна получать местоположение пользователя, если это возможно
class SimpleMapBlocInitEvent extends SimpleMapBlocEvent {
  final GoogleMapController controller;

  SimpleMapBlocInitEvent(this.controller);

  @override
  List<Object> get props => [];
}

/// Событие для поиска позиции пользователя
class SimpleMapBlocFindLocation extends SimpleMapBlocEvent {
  @override
  List<Object> get props => [];
}

/// Добавление мест в состояние, которые были загружены.
/// Места не хранятся в блоке, а передаются в UI, чтобы там из них были сделаны
/// маркеры.
class SimpleMapBlocAddPlaces extends SimpleMapBlocEvent {
  final FutureResponse<List<ClippedVisitPlace>> places;

  SimpleMapBlocAddPlaces(this.places);

  @override
  List<Object> get props => [places];
}
