import 'package:city_go/app/widgets/path_map/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

class MockMapRepo extends Mock implements MapRepository {}

class MockGeolocator extends Mock implements Geolocator {}

class MockMapController extends Mock implements GoogleMapController {}

void main() {
  final userPosition = LatLng(31.0, 12.0);
  final dest = LatLng(30.0, 12.0);
  final walk = PathType.Walk;
  final car = PathType.Car;

  MockMapRepo repo;
  MockMapController controller;
  MockGeolocator geolocator;

  PathMapBloc bloc;

  setUp(() {
    repo = MockMapRepo();
    geolocator = MockGeolocator();
    controller = MockMapController();
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
        when(geolocator.getCurrentPosition()).thenThrow(Exception(''));

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getCurrentPosition());
      },
    );

    test(
      '''должен инициализировать позицию пользователя с ошибкой, а также не 
      должен инициализировать точки маршрута (нет позиции пользователя)''',
      () async {
        // arrange
        when(geolocator.getCurrentPosition()).thenThrow(Exception(''));

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.fail(LOCATION_ACCESS_DENIED),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getCurrentPosition());
      },
    );

    test(
      'должен инициализировать позицию пользователя',
      () async {
        // arrange
        when(geolocator.getCurrentPosition()).thenAnswer(
          (_) => Future.value(Position(
              latitude: userPosition.latitude,
              longitude: userPosition.longitude)),
        );

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getCurrentPosition());
      },
    );

    test(
      'должен инициализировать точки маршрута с ошибкой',
      () async {
        // arrange
        when(geolocator.getCurrentPosition()).thenAnswer(
          (_) => Future.value(Position(
              latitude: userPosition.latitude,
              longitude: userPosition.longitude)),
        );
        when(repo.calculatePathBetweenPoints(any, any, any))
            .thenAnswer((_) => Future.value(FutureResponse.fail(NO_INTERNET)));

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.fail(NO_INTERNET),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getCurrentPosition());
        verify(repo.calculatePathBetweenPoints(userPosition, dest, walk));
      },
    );

    test(
      'должен инициализировать точки маршрута успешно',
      () async {
        // arrange
        when(geolocator.getCurrentPosition()).thenAnswer(
          (_) => Future.value(Position(
              latitude: userPosition.latitude,
              longitude: userPosition.longitude)),
        );
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(
            FutureResponse.success(MapRoute(10, [userPosition, dest])),
          ),
        );

        // act
        bloc.add(PathMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.success(MapRoute(10, [userPosition, dest])),
              type: walk,
            )
          ]),
        );
        verify(geolocator.getCurrentPosition());
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
        when(repo.calculatePathBetweenPoints(any, any, any)).thenAnswer(
          (_) => Future.value(
            FutureResponse.success(MapRoute(10, [userPosition, dest])),
          ),
        );

        // act
        bloc.add(PathMapBlocChangeType(car));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            PathMapBlocMapState(
              controller: controller,
              userPosition: FutureResponse.success(userPosition),
              route: FutureResponse.success(MapRoute(10, [userPosition, dest])),
              type: car,
            )
          ]),
        );
        verify(repo.calculatePathBetweenPoints(userPosition, dest, car));
      },
    );
  });
}
