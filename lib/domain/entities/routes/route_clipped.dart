import 'package:city_go/domain/entities/visit_place/image_src.dart';
import 'package:equatable/equatable.dart';

/// Обрезанная модель маршрута, которая содержит лишь информацию,
/// которая отображается в карточке маршрута.
class RouteClipped extends Equatable {
  final int id;
  final String title;
  final ImageSrc image;
  final double rating;

  /// Длина маршрута в километрах
  final double length;

  RouteClipped(this.id, this.title, this.length, this.image, this.rating);

  factory RouteClipped.fromJson(Map<String, dynamic> json) {
    return RouteClipped(
      json['id'],
      json['title'],
      json['length'],
      ImageSrc.fromJson(json['image']),
      json['rating'],
    );
  }

  @override
  List<Object> get props => [id, title, length, image, rating];
}
