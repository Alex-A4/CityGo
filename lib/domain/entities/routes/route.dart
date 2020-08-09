import 'package:city_go/domain/entities/routes/route_cord.dart';
import 'package:city_go/domain/entities/routes/route_place.dart';

/// Сущность описания пешего маршрута.
class Route {
  final int id;
  final String title;
  final String description;
  final double rating;

  /// Длина маршрута в километрах
  final double length;

  /// Время для преодоления маршрута. Используется строка на всякий случай
  final String goTime;
  final String generalInfo;
  final String audio;

  /// Список координат, через которые проходит маршрут
  final List<RouteCord> cords;

  /// Список мест, через которые проходит маршрут
  final List<RoutePlace> routePlaces;

    Route(this.id, this.title, this.description, this.rating, this.length,
      this.goTime, this.generalInfo, this.audio, this.routePlaces, this.cords);

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
    );
  }
}
