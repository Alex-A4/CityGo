import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/lat_lng.dart';

import 'package:meta/meta.dart';

import 'image_src.dart';
export 'image_src.dart';

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
  final List<ImageSrc> imageSrc;

  /// Эндпоинт аудио файла, может отсутствовать (null)
  final String audioSrc;

  /// Общая информация об объекте
  final String generalInfo;

  FullVisitPlace({
    @required int id,
    LatLng latLng,
    @required String title,
    @required String workTime,
    @required double rating,
    @required String logo,
    @required PlaceType type,
    @required this.description,
    @required this.imageSrc,
    @required this.objectAddress,
    @required this.generalInfo,
    this.objectWebSite,
    this.audioSrc,
  }) : super(id, type, title, workTime, rating, logo, latLng);

  factory FullVisitPlace.fromJson(Map<String, dynamic> json) {
    return FullVisitPlace(
      id: json['id'],
      type: PlaceType.values[json['type'] ?? 3],
      title: json['name'] ?? '',
      workTime: json['work_time'] ?? '',
      rating: json['rating'] ?? 0.0,
      logo: json['logo'],
      imageSrc: json['images']
              ?.map<ImageSrc>((i) => ImageSrc.fromJson(i))
              ?.toList() ??
          [],
      description: json['description'] ?? '',
      objectAddress: json['address'] ?? '',
      audioSrc: json['audio'],
      objectWebSite: json['website'] ?? '',
      generalInfo: json['general'] ?? '',
      latLng: LatLng.fromJson(json['coords']),
    );
  }

  @override
  List<Object> get props => [...super.props, objectAddress, latLng];
}
