import 'package:city_go/constants.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/data/repositories/map/distance_calculator.dart';
import 'package:city_go/data/repositories/map/map_repository_impl.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'map_repo_test.mocks.dart';

@GenerateMocks([PolylinePoints, DistanceCalculator, NetworkChecker])
void main() {
  final start = g.LatLng(31.0, 12.0);
  final dest = g.LatLng(32.0, 12.0);
  final car = PathType.Car;
  final walk = PathType.Walk;
  final route = Route.fromJson({
    'id': 0,
    'length': 20.0,
    'parts': [
      {'order': 3, 'lat': 33.0, 'lng': 0.0},
      {'order': 1, 'lat': 31.0, 'lng': 0.0},
      {'order': 2, 'lat': 32.0, 'lng': 0.0},
    ]
  });

  late MockDistanceCalculator calculator;
  late MapRepository mapRepository;
  late MockPolylinePoints polyline;
  late MockNetworkChecker checker;

  setUp(() {
    calculator = MockDistanceCalculator();
    checker = MockNetworkChecker();
    polyline = MockPolylinePoints();
    mapRepository = MapRepositoryImpl(polyline, checker, calculator);
  });

  group('calculatePathBetweenPoints', () {
    test(
      'должен вернуть ошибку нет интернета',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // act
        final response =
            await mapRepository.calculatePathBetweenPoints(start, dest, walk);

        // assert
        verify(checker.hasInternet);
        expect(response.errorCode, NO_INTERNET);
      },
    );

    test(
      'должен сделать запрос с пешим режимом',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          polyline.getRouteBetweenCoordinates(any, any, any,
              travelMode: anyNamed('travelMode')),
        ).thenAnswer(
          (_) => Future.value(PolylineResult(points: [], errorMessage: 'fas')),
        );

        // act
        await mapRepository.calculatePathBetweenPoints(start, dest, walk);

        // assert
        verify(polyline.getRouteBetweenCoordinates(MAP_API_KEY, any, any,
            travelMode: TravelMode.walking));
      },
    );

    test(
      'должен сделать запрос с режимом на машине',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          polyline.getRouteBetweenCoordinates(any, any, any,
              travelMode: anyNamed('travelMode')),
        ).thenAnswer(
          (_) => Future.value(PolylineResult(points: [], errorMessage: 'fas')),
        );

        // act
        await mapRepository.calculatePathBetweenPoints(start, dest, car);

        // assert
        verify(polyline.getRouteBetweenCoordinates(MAP_API_KEY, any, any,
            travelMode: TravelMode.driving));
      },
    );

    test(
      'должен вернуть неожиданную ошибку (проблема в плагине)',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          polyline.getRouteBetweenCoordinates(any, any, any,
              travelMode: anyNamed('travelMode')),
        ).thenAnswer(
          (_) => Future.value(PolylineResult(points: [], errorMessage: 'fas')),
        );

        // act
        final response =
            await mapRepository.calculatePathBetweenPoints(start, dest, walk);

        // assert
        verify(checker.hasInternet);
        verify(polyline.getRouteBetweenCoordinates(MAP_API_KEY, any, any,
            travelMode: TravelMode.walking));
        expect(response.errorCode, UNEXPECTED_ERROR);
      },
    );

    test(
      'должен вернуть результат',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          polyline.getRouteBetweenCoordinates(any, any, any,
              travelMode: anyNamed('travelMode')),
        ).thenAnswer(
          (_) => Future.value(PolylineResult(points: [
            PointLatLng(start.latitude, start.longitude),
            PointLatLng(dest.latitude, dest.longitude),
          ])),
        );
        when(calculator.coordinateDistance(any, any, any, any))
            .thenReturn(10.0);

        // act
        final response =
            await mapRepository.calculatePathBetweenPoints(start, dest, walk);

        // assert
        verify(checker.hasInternet);
        verify(polyline.getRouteBetweenCoordinates(MAP_API_KEY, any, any,
            travelMode: TravelMode.walking));
        expect(response.data, MapRoute(10.0, [start, dest]));
      },
    );
  });

  group('calculatePathForRoute', () {
    test(
      'должен вернуть ошибку нет интернета',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // act
        final response = await mapRepository.calculatePathForRoute(route);

        // assert
        verify(checker.hasInternet);
        expect(response.errorCode, NO_INTERNET);
      },
    );

    test(
      'должен вернуть неожиданную ошибку (проблема в плагине)',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          polyline.getRouteBetweenCoordinates(any, any, any,
              travelMode: anyNamed('travelMode')),
        ).thenAnswer(
          (_) => Future.value(PolylineResult(points: [], errorMessage: 'fas')),
        );

        // act
        final response = await mapRepository.calculatePathForRoute(route);

        // assert
        verify(checker.hasInternet);
        verify(polyline.getRouteBetweenCoordinates(MAP_API_KEY, any, any,
            travelMode: TravelMode.walking));
        expect(response.errorCode, UNEXPECTED_ERROR);
      },
    );

    test(
      'должен вернуть результат',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          polyline.getRouteBetweenCoordinates(any, any, any,
              travelMode: anyNamed('travelMode')),
        ).thenAnswer(
          (_) => Future.value(PolylineResult(points: [
            PointLatLng(start.latitude, start.longitude),
            PointLatLng(dest.latitude, dest.longitude),
          ])),
        );

        // act
        final response = await mapRepository.calculatePathForRoute(route);

        // assert
        verify(checker.hasInternet);
        verify(polyline.getRouteBetweenCoordinates(MAP_API_KEY, any, any,
                travelMode: TravelMode.walking))
            .called(2);

        /// Список точек указывается для каждой пары
        expect(
          response.data,
          MapRoute(route.length, [start, dest, start, dest]),
        );
      },
    );
  });
}
