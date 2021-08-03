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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'route_map_bloc_test.mocks.dart';

@GenerateMocks([
  MapRepository,
  GoogleMapController,
  Geolocator,
  MapIconsStorage,
])
void main() {
  final userPosition = LatLng(31.0, 12.0);
  final cord1 = LatLng(41.53, 41.47);
  final cord2 = LatLng(41.512, 41.87);
  final images = <BitmapDescriptor>[];
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

  late RouteMapBloc bloc;
  late MockMapRepository repo;
  late MockGoogleMapController controller;
  late MockGeolocator geolocator;
  late MockMapIconsStorage iconsStorage;

  setUp(() {
    geolocator = MockGeolocator();
    repo = MockMapRepository();
    iconsStorage = MockMapIconsStorage();
    controller = MockGoogleMapController();
    bloc = RouteMapBloc(route, repo, geolocator, iconsStorage);
  });

  test(
    'должен инициализироваться с состоянием без данных',
    () async {
      // assert
      expect(bloc.state, RouteMapBlocState());
    },
  );

  group('RouteMapBlocInitEvent', () {
    test(
      'должен инициализировать гугл контроллер',
      () async {
        // arrange
        when(controller.mapId).thenReturn(0);
        when(iconsStorage.future).thenAnswer((_) => Future.value(images));
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(repo.calculatePathForRoute(any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(mapRoute)),
        );

        // act
        bloc.add(RouteMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            RouteMapBlocState(
              controller: controller,
              isLocationSearching: true,
            ),
            RouteMapBlocState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            ),
          ]),
        );

        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута с ошибкой',
      () async {
        // arrange
        when(controller.mapId).thenReturn(0);
        when(iconsStorage.future).thenAnswer((_) => Future.value(images));
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(repo.calculatePathForRoute(any))
            .thenAnswer((_) => Future.value(FutureResponse.fail(NO_INTERNET)));

        // act
        bloc.add(RouteMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            RouteMapBlocState(
              controller: controller,
              isLocationSearching: true,
            ),
            RouteMapBlocState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            ),
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.fail(NO_INTERNET),
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            )
          ]),
        );
        verify(repo.calculatePathForRoute(route));
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута успешно',
      () async {
        // arrange
        when(iconsStorage.future).thenAnswer((_) => Future.value(images));
        when(controller.mapId).thenReturn(0);
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
          bloc.stream,
          emitsInOrder([
            RouteMapBlocState(
              controller: controller,
              isLocationSearching: true,
            ),
            RouteMapBlocState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
            ),
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.success(userPosition),
            ),
          ]),
        );

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
        when(controller.mapId).thenReturn(0);
        bloc.mapRoute = FutureResponse.success(mapRoute);
        when(geolocator.getPosition()).thenThrow(LOCATION_SERVICE_DISABLED);

        // act
        bloc.add(RouteMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              isLocationSearching: true,
            ),
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.fail(LOCATION_SERVICE_DISABLED),
            ),
          ]),
        );

        verify(geolocator.getPosition());
      },
    );

    test(
      'должен завершить поиск с ошибкой, что доступа нет',
      () async {
        // arrange
        bloc.controller = controller;
        when(controller.mapId).thenReturn(0);
        bloc.mapRoute = FutureResponse.success(mapRoute);
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);

        // act
        bloc.add(RouteMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              isLocationSearching: true,
            ),
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
            )
          ]),
        );

        verify(geolocator.getPosition());
      },
    );

    test(
      'должен завершить поиск позиции успешно',
      () async {
        // arrange
        bloc.controller = controller;
        when(controller.mapId).thenReturn(0);
        bloc.mapRoute = FutureResponse.success(mapRoute);
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));

        // act
        bloc.add(RouteMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              isLocationSearching: true,
            ),
            RouteMapBlocState(
              controller: controller,
              route: FutureResponse.success(mapRoute),
              userPosition: FutureResponse.success(userPosition),
            ),
          ]),
        );

        verify(geolocator.getPosition());
      },
    );
  });
}
