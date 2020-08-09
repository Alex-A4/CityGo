import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:city_go/domain/entities/routes/route_cord.dart';
import 'package:city_go/domain/entities/routes/route_place.dart';

/// Сущность описания пешего маршрута.
class Route extends RouteClipped {
  final String description;

  /// Время для преодоления маршрута. Используется строка на всякий случай
  final String goTime;
  final String generalInfo;
  final String audio;

  /// Список координат, через которые проходит маршрут
  final List<RouteCord> cords;

  /// Список мест, через которые проходит маршрут
  final List<RoutePlace> routePlaces;

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
      json['places']?.map<RoutePlace>((p) => RoutePlace.fromJson(p))?.toList(),
      json['cords']?.map<RouteCord>((c) => RouteCord.fromJson(c))?.toList(),
      ImageSrc.fromJson(json['image']),
    );
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
