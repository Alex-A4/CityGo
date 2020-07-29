import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/lat_lng.dart';

import 'package:meta/meta.dart';

/// Описание полного объекта места, которое может посетить пользователь.
/// Полная модель содержит расширенную информацию об объекте.
class FullVisitPlace extends ClippedVisitPlace {
  /// Адрес объекта
  final String objectAddress;

  /// Веб-сайт объекта, может отсутствовать (null)
  final String objectWebSite;

  /// Описание объекта
  final String description;

  /// Список эндпоинтов изображений, может быть пустым
  final List<String> imageSrc;

  /// Эндпоинт аудио файла, может отсутствовать (null)
  final String audioSrc;

  /// Общая информация об объекте
  final String generalInfo;

  /// Координаты расположения объекта
  final LatLng latLng;

  FullVisitPlace({
    @required int id,
    @required String title,
    @required String workTime,
    @required double rating,
    @required this.description,
    @required this.imageSrc,
    @required this.objectAddress,
    @required this.generalInfo,
    @required this.latLng,
    this.objectWebSite,
    this.audioSrc,
  }) : super(id, title, workTime, rating);

  factory FullVisitPlace.fromJson(Map<String, dynamic> json) {
    return FullVisitPlace(
      id: json['id'],
      title: json['name'],
      workTime: json['workTime'],
      rating: json['rating'],
      imageSrc: json['imgs'] ?? [],
      description: json['description'],
      objectAddress: json['address'],
      audioSrc: json['audio'],
      objectWebSite: json['website'],
      generalInfo: json['general'],
      latLng: LatLng.fromJson(json['cords']),
    );
  }
}