import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:meta/meta.dart';

/// Абстрактный репозиторий маршрутов, который позволяет загружать как список
/// маршрутов, так и отдельные информации о них.
abstract class RouteRepository {
  /// Получение списка маршрутов в обрезанных моделях.
  /// [token] - токен авторизации пользователя
  /// [offset] - смещение для пагинации.
  Future<FutureResponse<List<RouteClipped>>> getRoutes(
      {@required String token, @required int offset});

  /// Получение полной информации о маршруте.
  /// [id] - идентификатор маршрута, который нужно загрузить
  /// [token] - токен авторизации пользователя.
  Future<FutureResponse<Route>> getRoute(
      {@required int id, @required String token});

  /// Метод для выставления оценки месту
  /// [routeId] - идентификатор маршрута
  /// [value] - оценка маршруту, которую поставил пользователь
  /// [token] - токен авторизации пользователем на нашем сервере.
  /// [userId] - идентификатор пользователя на нашем сервере.
  Future<FutureResponse<bool>> rateRoute({
    @required int routeId,
    @required int value,
    @required String token,
    @required int userId,
  });
}
