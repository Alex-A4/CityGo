import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;

/// Объект, описывающий широту и долготу
class LatLng extends Equatable {
  /// Широта
  final double latitude;

  /// Долгота
  final double longitude;

  LatLng(this.latitude, this.longitude);

  static LatLng? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return LatLng(json['lat'], json['lng']);
  }

  /// Конвертация класса в гугл координаты
  g.LatLng toGoogle() => g.LatLng(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}
