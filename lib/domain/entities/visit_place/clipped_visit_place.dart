import 'package:city_go/domain/entities/lat_lng.dart';
import 'package:equatable/equatable.dart';

/// Обрезанная модель объектов для посещения.
/// Используется в списке, который отображает места по категориям.
/// Данная модель является универсальной и подходит для описания любого объекта.
class ClippedVisitPlace extends Equatable {
  /// Идентификатор на сервере
  final int id;

  /// Заголовок, который описывает карточку
  final String name;

  final PlaceType type;

  /// Время работы объекта, может не содержать информации, например, для парков.
  /// Если время не указано, то это пустая строка
  final String workTime;

  /// Рейтинг объекта
  final double rating;

  final String logo;

  /// Координаты расположения объекта
  final LatLng latLng;

  final String generalInfo;

  ClippedVisitPlace(this.id, this.type, this.name, this.workTime, this.rating,
      this.logo, this.latLng, this.generalInfo);

  /// Фабрика для извлечения данных из JSON
  factory ClippedVisitPlace.fromJson(Map<String, dynamic> json) {
    return ClippedVisitPlace(
      json['id'],
      PlaceType.values[(json['type'] ?? 3) - 1],
      json['name'] ?? '',
      json['work_time'] ?? '',
      json['rating'] ?? 0.0,
      json['logo'],
      LatLng.fromJson(json['coords']),
      json['general'] ?? '',
    );
  }

  @override
  List<Object> get props =>
      [id, name, workTime, rating, logo, type, latLng, generalInfo];
}

/// Тип объекта, который
enum PlaceType {
  Museums,
  Restaurants,
  Cathedrals,
  ActiveRecreation,
  Parks,
  Pubs,
  Theatres,
  Malls,
}

/// Расширение для получения названия места по его типу, а также индесков
/// иконок в [MapIconsStorage].
/// Используется в репозитории, чтобы упростить формирование данных
extension PlaceTypeSupport on PlaceType {
  /// Получение названия типа, используется в локализации.
  String get placeName {
    switch (this) {
      case PlaceType.Museums:
        return 'museums';
      case PlaceType.Restaurants:
        return 'restaurants';
      case PlaceType.Cathedrals:
        return 'cathedrals';
      case PlaceType.ActiveRecreation:
        return 'activeRecreation';
      case PlaceType.Parks:
        return 'parks';
      case PlaceType.Pubs:
        return 'pubs';
      case PlaceType.Theatres:
        return 'theatres';
      case PlaceType.Malls:
        return 'malls';
      default:
        return null;
    }
  }

  /// Получение индекса в репозитории иконок для карты.
  /// Иконки распределились по группировкам.
  int get iconIndex {
    switch (this) {
      case PlaceType.Restaurants:
      case PlaceType.Pubs:
        return 0;
      case PlaceType.Cathedrals:
      case PlaceType.Museums:
      case PlaceType.Theatres:
        return 1;
      case PlaceType.ActiveRecreation:
      case PlaceType.Parks:
      case PlaceType.Malls:
        return 2;
      default:
        return 0;
    }
  }
}
