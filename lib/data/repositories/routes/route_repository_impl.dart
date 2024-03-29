import 'dart:io';

import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:city_go/domain/repositories/routes/route_repository.dart';
import 'package:dio/dio.dart';

export 'package:city_go/domain/repositories/routes/route_repository.dart';

/// Реализация репозитория по загрузке маршрутов.
class RouteRepositoryImpl implements RouteRepository {
  static const ROUTE_PATH = '/api/routes/';
  static const count = 15;
  final HttpClient client;
  final NetworkChecker checker;

  RouteRepositoryImpl(this.client, this.checker);

  @override
  Future<FutureResponse<List<RouteClipped>>> getRoutes({
    required String token,
    required int offset,
  }) async {
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      final response = await client.get(
        ROUTE_PATH,
        queryParameters: {'offset': offset, 'limit': count},
        options: Options(
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: 'Token $token'},
        ),
      );

      if (response.statusCode != 200) throw '';

      var routes = <RouteClipped>[];
      response.data['results']
          .forEach((r) => routes.add(RouteClipped.fromJson(r)));
      return FutureResponse.success(routes);
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(e.toString());
    }
  }

  @override
  Future<FutureResponse<Route>> getRoute({
    required int id,
    required String token,
  }) async {
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      final response = await client.get(
        ROUTE_PATH + '$id',
        options: Options(
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: 'Token $token'},
        ),
      );

      if (response.statusCode != 200) throw '';
      return FutureResponse.success(Route.fromJson(response.data));
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(e.toString());
    }
  }

  @override
  Future<FutureResponse<bool>> rateRoute({
    required int routeId,
    required int value,
    required String token,
    required int userId,
  }) async {
    assert(value >= 1 && value <= 5);

    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      await client.post(
        '/api/votes/route/',
        data: {'value': value, 'user': userId, 'route': routeId},
        options: Options(
          headers: {HttpHeaders.authorizationHeader: 'Token $token'},
        ),
      );

      return FutureResponse.success(true);
    } on DioError catch (e) {
      final overrideMap = <int, String>{};
      if (e.response?.data['non_field_errors'] != null)
        overrideMap[400] = 'rate_already_complete';
      return FutureResponse.fail(handleDioError(e, overrideData: overrideMap));
    } catch (e) {
      return FutureResponse.fail(e.toString());
    }
  }
}
