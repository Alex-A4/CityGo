import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Состояние для простой карты
abstract class SimpleMapBlocState extends Equatable {}

/// Состояние карты, которое содержит определенный набор данных, которые необходимы
/// карте.
class SimpleMapBlocMapState extends SimpleMapBlocState {
  /// Контроллер карты, с помощью которого идёт взаимодействие с картой
  /// Может быть null.
  final GoogleMapController controller;
  final List<ClippedVisitPlace> places;

  /// Позиция пользователя на карте. Может быть равна null, если отключена геопозиция
  /// Если при получении позиции возникла ошибка, то она будет отображена в
  /// качестве уведомления пользователю.
  /// Может быть null.
  final FutureResponse<LatLng> userPosition;

  final bool isLocationSearching;
  final String errorCode;

  SimpleMapBlocMapState({
    this.places,
    this.controller,
    this.userPosition,
    this.isLocationSearching = false,
    this.errorCode,
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        controller?.mapId,
        places,
        userPosition,
        isLocationSearching,
        errorCode,
      ];
}
