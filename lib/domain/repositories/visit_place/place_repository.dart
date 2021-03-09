import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

export 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
export 'package:city_go/domain/entities/visit_place/full_visit_place.dart';

/// Способ сортировки мест
enum PlaceSortType { Distance, Rating, Random }

/// Получение строкового названия типа сортировки
extension PlaceSortString on PlaceSortType {
  String get sortName {
    switch (this) {
      case PlaceSortType.Distance:
        return 'distance';
      case PlaceSortType.Rating:
        return 'rating';
      case PlaceSortType.Random:
        return 'random';
    }
  }
}

/// Репозиторий, который позволяет загружать сущности объектов, которые можно
/// посетить.
abstract class PlaceRepository {
  /// Получение списка обрезанных мест по входным параметрам.
  /// [offset] - параметр для реализации пагинации.
  /// [placeType] - тип объекта, который нужно получить
  /// [sortType] - способ сортировки.
  /// [token] - токен авторизации пользователем на нашем сервере.
  /// [latLng] - координаты, относительно которых нужно делать сортировку, если
  /// пользователь выбрал сортировку по близости.
  Future<FutureResponse<List<ClippedVisitPlace>>> getPlaces({
    required PlaceType placeType,
    required String token,
    required int offset,
    required PlaceSortType sortType,
    LatLng? latLng,
  });

  /// Получение полного объекта конкретного места.
  /// [id] - идентификатор места, который можно получить из [ClippedVisitPlace.id]
  /// [token] - токен авторизации пользователем на нашем сервере.
  Future<FutureResponse<FullVisitPlace>> getConcretePlace({
    required int id,
    required String token,
  });

  /// Метод для выставления оценки месту
  /// [placeId] - идентификатор места, который можно получить из [ClippedVisitPlace.id]
  /// [token] - токен авторизации пользователем на нашем сервере.
  /// [userId] - идентификатор пользователя на нашем сервере.
  /// [value] - оценка месту, которую поставил пользователь
  Future<FutureResponse<bool>> ratePlace({
    required int value,
    required int placeId,
    required String token,
    required int userId,
  });

  /// Получение всех объектов всех типов по порядку.
  /// Все объекты будут передоваться в порядке загрузки и пагинации.
  /// В случае возникновения ошибки, она будет передана, а стрим закончит загрузку.
  /// [token] - токен авторизации пользователя на нашем сервере.
  /// [sort] - тип сортировки, является опциональным.
  Stream<FutureResponse<List<ClippedVisitPlace>>> getAllPlacesStream({
    required String token,
    PlaceSortType sort = PlaceSortType.Rating,
  });
}
