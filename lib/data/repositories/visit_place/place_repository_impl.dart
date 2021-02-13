import 'dart:io';

import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

export 'package:city_go/domain/entities/future_response.dart';
export 'package:city_go/domain/repositories/visit_place/place_repository.dart';

class PlaceRepositoryImpl extends PlaceRepository {
  static const PLACE_PATH = '/api/places/';
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
    LatLng latLng,
  }) async {
    assert(placeType != null &&
        token != null &&
        offset != null &&
        sortType != null);
    assert(latLng != null && sortType == PlaceSortType.Distance ||
        sortType != PlaceSortType.Distance);
    try {
      if (!await checker.hasInternet) throw NO_INTERNET;
      final params = {
        'type': placeType.index + 1,
        'sort': sortType.sortName,
        'limit': count,
        'offset': offset,
      };
      if (latLng != null) {
        params['lat'] = latLng.latitude;
        params['lng'] = latLng.longitude;
      }

      var response = await client.get(
        PLACE_PATH,
        queryParameters: params,
        options: Options(
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: 'Token $token'},
        ),
      );

      if (response.statusCode != 200) throw '';

      var places = <ClippedVisitPlace>[];
      response.data['results']
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
        PLACE_PATH + '$id',
        options: Options(
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: 'Token $token'},
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

  @override
  Stream<FutureResponse<List<ClippedVisitPlace>>> getAllPlacesStream({
    @required String token,
    PlaceSortType sort = PlaceSortType.Rating,
  }) async* {
    assert(sort != null);
    for (final type in PlaceType.values) {
      int typeResults = 0;
      while (true) {
        final res = await getPlaces(
          placeType: type,
          token: token,
          offset: typeResults,
          sortType: sort,
        );

        /// Если нет данных для этого типа (все уже загрузили).
        if (res.hasData && res.data.isEmpty) break;
        if (res.hasData) typeResults += res.data.length;

        yield res;
        if (res.hasError) return;
      }
    }
  }

  @override
  Future<FutureResponse<bool>> ratePlace({
    @required int value,
    @required int placeId,
    @required String token,
    @required int userId,
  }) async {
    assert(value >= 1 && value <= 5);
    assert(token != null && userId != null);

    try {
      if (!await checker.hasInternet) throw NO_INTERNET;

      await client.post(
        '/api/votes/place/',
        data: {'value': value, 'user': userId, 'place': placeId},
        options: Options(
          headers: {HttpHeaders.authorizationHeader: 'Token $token'},
        ),
      );

      return FutureResponse.success(true);
    } on DioError catch (e) {
      final overrideMap = <int, String>{};
      if (e.response.data['non_field_errors'] != null)
        overrideMap[400] = 'rate_already_complete';
      return FutureResponse.fail(handleDioError(e, overrideData: overrideMap));
    } catch (e) {
      return FutureResponse.fail(e.toString());
    }
  }
}
