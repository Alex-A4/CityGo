import 'dart:io';

import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

export 'package:city_go/domain/entities/future_response.dart';
export 'package:city_go/domain/repositories/visit_place/place_repository.dart';

class PlaceRepositoryImpl extends PlaceRepository {
  static const PLACE_PATH = '/places';
  static const count = 15;
  final HttpClient client;
  final NetworkChecker checker;

  PlaceRepositoryImpl(this.client, this.checker);

  @override
  Future<FutureResponse<List<ClippedVisitPlace>>> getPlaces({
    @required PlaceType placeType,
    @required String token,
    @required int offset,
    @required PlaceSortType sortType,
  }) async {
    assert(placeType != null &&
        token != null &&
        offset != null &&
        sortType != null);
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      var response = await client.get(
        PLACE_PATH,
        queryParameters: {
          'type': placeType.placeName,
          'sort': sortType.sortName,
          'count': count,
          'offset': offset,
        },
        options: Options(
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) throw '';

      var places = <ClippedVisitPlace>[];
      response.data['result']
          .forEach((p) => places.add(ClippedVisitPlace.fromJson(p)));
      return FutureResponse.success(places);
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(e.toString());
    }
  }

  @override
  Future<FutureResponse<FullVisitPlace>> getConcretePlace({
    @required int id,
    @required String token,
  }) async {
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      var response = await client.get(
        PLACE_PATH + '/$id',
        options: Options(
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) throw '';

      return FutureResponse.success(FullVisitPlace.fromJson(response.data));
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(e.toString());
    }
  }
}
