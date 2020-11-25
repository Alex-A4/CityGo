import 'package:city_go/app/widgets/route_map/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/storages/map_icons_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

class MockMapRepo extends Mock implements MapRepository {}

class MockMapController extends Mock implements GoogleMapController {}

class MockGeolocator extends Mock implements Geolocator {}

class MockIconsStorage extends Mock implements MapIconsStorage {}

void main() {
  final userPosition = LatLng(31.0, 12.0);
  final cord1 = LatLng(41.53, 41.47);
  final cord2 = LatLng(41.512, 41.87);
  final json = <String, dynamic>{
    'id': 123,
    'title': 'Some title',
    'rating': 3.1,
    'length': 2.1,
    'image': {
      'title': 'some title',
      'description': 'Some description',
      'image': '/src/image.jpg',
    },
    'cords': [
      {
        'lat': cord1.latitude,
        'lng': cord1.longitude,
        'order': 1,
      },
      {
        'lat': cord2.latitude,
        'lng': cord2.longitude,
        'order': 2,
      },
    ],
  };
  final route = Route.fromJson(json);
  final mapRoute = MapRoute(10, [cord1, cord2]);

  // ignore: close_sinks
  RouteMapBloc bloc;
  MockMapRepo repo;
  MockMapController controller;
  MockGeolocator geolocator;
  MockIconsStorage iconsStorage;

  setUp(() {
    geolocator = MockGeolocator();
    repo = MockMapRepo();
    iconsStorage = MockIconsStorage();
    controller = MockMapController();
    bloc = RouteMapBloc(route, repo, geolocator, iconsStorage);
  });

  test(
    'должен инициализироваться с состоянием без данных',
    () async {
      // assert
      expect(bloc.state, RouteMapBlocMapState());
    },
  );

  group('RouteMapBlocInitEvent', () {
    test(
      'должен инициализировать гугл контроллер',
      () async {
        // arrange
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);

        // act
        bloc.add(RouteMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteMapBlocMapState(
              controller: controller,
              isLocationSearching: true,
            ),
            RouteMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            ),
          ]),
        );

        expect(bloc.showError, isTrue);
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута с ошибкой',
      () async {
        // arrange
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(repo.calculatePathForRoute(any))
            .thenAnswer((_) => Future.value(FutureResponse.fail(NO_INTERNET)));

        // act
        bloc.add(RouteMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteMapBlocMapState(
              controller: controller,
              isLocationSearching: true,
            ),
            RouteMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            ),
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.fail(NO_INTERNET),
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            )
          ]),
        );
        expect(bloc.showError, isTrue);
        verify(repo.calculatePathForRoute(route));
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута успешно',
      () async {
        // arrange
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(repo.calculatePathForRoute(any)).thenAnswer(
          (_) => Future.value(
            FutureResponse.success(mapRoute),
          ),
        );

        // act
        bloc.add(RouteMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteMapBlocMapState(
              controller: controller,
              isLocationSearching: true,
            ),
            RouteMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
            ),
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.success(userPosition),
            ),
          ]),
        );

        expect(bloc.showError, isFalse);
        verify(repo.calculatePathForRoute(route));
        verify(geolocator.getPosition());
      },
    );
  });

  group('RouteMapBlocFindLocation', () {
    test(
      'должен завершить поиск с ошибкой, что сервис выключен',
      () async {
        // arrange
        bloc.controller = controller;
        bloc.mapRoute = FutureResponse.success(mapRoute);
        when(geolocator.getPosition()).thenThrow(LOCATION_SERVICE_DISABLED);

        // act
        bloc.add(RouteMapBlocFindLocation());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              isLocationSearching: true,
            ),
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.fail(LOCATION_SERVICE_DISABLED),
            ),
          ]),
        );

        expect(bloc.showError, isTrue);
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен завершить поиск с ошибкой, что доступа нет',
      () async {
        // arrange
        bloc.controller = controller;
        bloc.mapRoute = FutureResponse.success(mapRoute);
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);

        // act
        bloc.add(RouteMapBlocFindLocation());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              isLocationSearching: true,
            ),
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            )
          ]),
        );

        expect(bloc.showError, isTrue);
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен завершить поиск позиции успешно',
      () async {
        // arrange
        bloc.controller = controller;
        bloc.mapRoute = FutureResponse.success(mapRoute);
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));

        // act
        bloc.add(RouteMapBlocFindLocation());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              isLocationSearching: true,
            ),
            RouteMapBlocMapState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.success(userPosition),
            ),
          ]),
        );

        expect(bloc.showError, isFalse);
        verify(geolocator.getPosition());
      },
    );
  });
}
