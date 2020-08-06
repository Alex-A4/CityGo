import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:meta/meta.dart';

export 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
export 'package:city_go/domain/entities/visit_place/full_visit_place.dart';

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

/// Способ сортировки мест
enum PlaceSortType { Proximity, Rating, Random }

/// Расширение для получения названия места по его типу.
/// Используется в репозитории, чтобы упростить формирование данных
extension PlaceTypeString on PlaceType {
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
}

/// Получение строкового названия типа сортировки
extension PlaceSortString on PlaceSortType {
  String get sortName {
    switch (this) {
      case PlaceSortType.Proximity:
        return 'proximity';
      case PlaceSortType.Rating:
        return 'rating';
      case PlaceSortType.Random:
        return 'random';
      default:
        return null;
    }
  }
}

/// Репозиторий, который позволяет загружать сущности объектов, которые можно
/// посетить.
abstract class PlaceRepository {
  /// Получение списка обрезанных мест по входным параметрам.
  /// [offset] и [count] - параметры для реализации пагинации.
  /// [placeType] - тип объекта, который нужно получить
  /// [sortType] - способ сортировки.
  /// [token] - токен авторизации пользователем на нашем сервере.
  Future<FutureResponse<List<ClippedVisitPlace>>> getPlaces({
    @required PlaceType placeType,
    @required String token,
    @required int offset,
    @required PlaceSortType sortType,
  });

  /// Получение полного объекта конкретного места.
  /// [id] - идентификатор места, который можно получить из [ClippedVisitPlace.id]
  /// [token] - токен авторизации пользователем на нашем сервере.
  Future<FutureResponse<FullVisitPlace>> getConcretePlace({
    @required int id,
    @required String token,
  });
}
