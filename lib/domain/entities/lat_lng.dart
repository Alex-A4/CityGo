import 'package:equatable/equatable.dart';

/// Объект, описывающий широту и долготу
class LatLng extends Equatable{
  /// Широта
  final double latitude;

  /// Долгота
  final double longitude;

  LatLng(this.latitude, this.longitude);

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(json['lat'], json['lng']);
  }

  @override
  List<Object> get props => [latitude, longitude];
}
