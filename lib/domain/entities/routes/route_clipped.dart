import 'package:equatable/equatable.dart';

/// Обрезанная модель маршрута, которая содержит лишь информацию,
/// которая отображается в карточке маршрута.
class RouteClipped extends Equatable {
  final int id;
  final String title;
  final String? logo;
  final double rating;

  /// Длина маршрута в километрах
  final double length;

  RouteClipped(this.id, this.title, this.length, this.logo, this.rating);

  factory RouteClipped.fromJson(Map<String, dynamic> json) {
    return RouteClipped(
      json['id'],
      json['title'] ?? '',
      json['length'] ?? 0.0,
      json['logo'],
      json['rating'] ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, title, length, logo, rating];
}
