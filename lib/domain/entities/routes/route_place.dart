import 'package:city_go/domain/entities/lat_lng.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';

/// Объект места, который прилагается к маршруту.
/// Используются поля, которые необходимы для отображения их на карте.
class RoutePlace extends ClippedVisitPlace {
  final String objectAddress;
  final String objectWebSite;
  final PlaceType type;
  final String generalInfo;
  final LatLng latLng;

  RoutePlace(
      int id,
      String name,
      String workTime,
      double rating,
      this.objectAddress,
      this.objectWebSite,
      this.type,
      this.generalInfo,
      this.latLng)
      : super(id, name, workTime, rating);

  factory RoutePlace.fromJson(Map<String, dynamic> json) {
    return RoutePlace(
      json['id'],
      json['name'],
      json['workTime'],
      json['rating'],
      json['address'],
      json['website'],
      PlaceType.values[json['type']],
      json['general'],
      LatLng.fromJson(json['cords']),
    );
  }
}
