import 'package:city_go/app/widgets/path_map/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'path_map_bloc_test.mocks.dart';

@GenerateMocks([MapRepository, Geolocator, GoogleMapController])
void main() {
  final userPosition = LatLng(31.0, 12.0);
  final dest = LatLng(30.0, 12.0);
  final route = MapRoute(5, [userPosition, dest]);
  final walk = PathType.Walk;
  final car = PathType.Car;

  late MockMapRepository repo;
  late MockGoogleMapController controller;
  late MockGeolocator geolocator;

  late PathMapBloc bloc;

  setUp(() {
    repo = MockMapRepository();
    geolocator = MockGeolocator();
    controller = MockGoogleMapController();
    bloc = PathMapBloc(repo, dest, geolocator);
  });

  test(
    'должен инициализироваться с состоянием без данных',
    () async {
      // assert
      expect(bloc.state, PathMapBlocMapState(type: walk));
    },
  );

  group('PathMapBlocInitEvent', () {
    test(
      'должен инициализировать гугл контроллер',
      () async {
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать позицию пользователя с ошибкой, что сервис выключен',
      () async {
        // arrange
        when(geolocator.getPosition()).thenThrow(LOCATION_SERVICE_DISABLED);
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_SERVICE_DISABLED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      '''должен инициализировать позицию пользователя с ошибкой, а также не 
      должен инициализировать точки маршрута (нет позиции пользователя)''',
      () async {
        // arrange
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать позицию пользователя',
      () async {
        // arrange
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(controller.mapId).thenReturn(0);
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(route)),
        );

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута с ошибкой',
      () async {
        // arrange
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(repo.calculatePathBetweenPoints(any, any, any))
            .thenAnswer((_) => Future.value(FutureResponse.fail(NO_INTERNET)));
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.fail(NO_INTERNET),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
        verify(repo.calculatePathBetweenPoints(userPosition, dest, walk));
      },
    );

    test(
      'должен инициализировать точки маршрута успешно',
      () async {
        // arrange
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(
            FutureResponse.success(MapRoute(10, [userPosition, dest])),
          ),
        );
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.success(MapRoute(10, [userPosition, dest])),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
        verify(repo.calculatePathBetweenPoints(userPosition, dest, walk));
      },
    );
  });

  group('PathMapBlocChangeType', () {
    test(
      'должен изменить тип и расчитать новые значения маршрута',
      () async {
        // arrange
        expect(bloc.type, walk);
        bloc.userPosition = FutureResponse.success(userPosition);
        bloc.controller = controller;
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(route)),
        );
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocChangeType(car));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.success(route),
              type: car,
            )
          ]),
        );
        verify(repo.calculatePathBetweenPoints(userPosition, dest, car));
      },
    );
  });

  group('PathMapBlocFindLocation', () {
    test(
      'должен инициализировать позицию пользователя с ошибкой, что сервис выключен',
      () async {
        // arrange
        bloc.controller = controller;
        when(geolocator.getPosition()).thenThrow(LOCATION_SERVICE_DISABLED);
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_SERVICE_DISABLED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      '''должен инициализировать позицию пользователя с ошибкой, а также не 
      должен инициализировать точки маршрута (нет позиции пользователя)''',
      () async {
        // arrange
        bloc.controller = controller;
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать позицию пользователя',
      () async {
        // arrange
        bloc.controller = controller;
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(route)),
        );
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута с ошибкой',
      () async {
        // arrange
        bloc.controller = controller;
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(repo.calculatePathBetweenPoints(any, any, any))
            .thenAnswer((_) => Future.value(FutureResponse.fail(NO_INTERNET)));
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.fail(NO_INTERNET),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
        verify(repo.calculatePathBetweenPoints(userPosition, dest, walk));
      },
    );

    test(
      'должен инициализировать точки маршрута успешно',
      () async {
        // arrange
        bloc.controller = controller;
        when(geolocator.getPosition())
            .thenAnswer((_) => Future.value(userPosition));
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(route)),
        );
        when(controller.mapId).thenReturn(0);

        // act
        bloc.add(PathMapBlocFindLocation());

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              type: walk,
              isLocationSearching: true,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            ),
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.success(route),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getPosition());
        verify(repo.calculatePathBetweenPoints(userPosition, dest, walk));
      },
    );
  });
}
