import 'package:city_go/domain/entities/lat_lng.dart';

/// Координаты маршрута, которые содержат номер метки для сортировки
class RouteCord extends LatLng {
  final int orderNumber;

  RouteCord(double latitude, double longitude, this.orderNumber)
      : super(latitude, longitude);

  factory RouteCord.fromJson(Map<String, dynamic> json) {
    return RouteCord(json['lat'], json['lng'], json['order']);
  }

  @override
  List<Object> get props => [...super.props, orderNumber];
}
