import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/lat_lng.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:city_go/domain/entities/routes/route_cord.dart';

/// Сущность описания пешего маршрута.
class Route extends RouteClipped {
  final String description;

  /// Время для преодоления маршрута. Используется строка на всякий случай
  final String goTime;
  final String generalInfo;
  final String audio;

  /// Список координат, через которые проходит маршрут
  final List<RouteCord> cords;

  /// Список мест, через которые проходит маршрут.
  /// Места не содержат картинок, описательной части, аудио.
  final List<FullVisitPlace> routePlaces;

  Route(
    int id,
    String title,
    this.description,
    double rating,
    double length,
    this.goTime,
    this.generalInfo,
    this.audio,
    this.routePlaces,
    this.cords,
    ImageSrc image,
  ) : super(id, title, length, image, rating);

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      json['id'],
      json['title'],
      json['description'],
      json['rating'],
      json['length'],
      json['goTime'],
      json['general'],
      json['audio'],
      json['places']
          ?.map<FullVisitPlace>((p) => FullVisitPlace.fromJson(p))
          ?.toList(),
      json['cords']?.map<RouteCord>((c) => RouteCord.fromJson(c))?.toList(),
      ImageSrc.fromJson(json['image']),
    );
  }

  /// Возвращает список координат в отсортированном порядке согласно их номеру
  List<LatLng> get sortedPoints {
    var points = <LatLng>[];
    cords.sort((c1, c2) => c1.orderNumber.compareTo(c2.orderNumber));
    cords.forEach((c) => points.add(LatLng(c.latitude, c.longitude)));
    return points;
  }

  @override
  List<Object> get props => [
        ...super.props,
        description,
        goTime,
        generalInfo,
        audio,
        cords,
        routePlaces,
      ];
}
