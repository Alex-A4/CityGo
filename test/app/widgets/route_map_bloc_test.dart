import 'package:city_go/app/widgets/route_map/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

class MockMapRepo extends Mock implements MapRepository {}

class MockMapController extends Mock implements GoogleMapController {}

void main() {
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

  // ignore: close_sinks
  RouteMapBloc bloc;
  MockMapRepo repo;
  MockMapController controller;

  setUp(() {
    repo = MockMapRepo();
    controller = MockMapController();
    bloc = RouteMapBloc(route, repo);
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
        // act
        bloc.add(RouteMapBlocInitEvent(controller));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([RouteMapBlocMapState(controller: controller)]),
        );
      },
    );


    test(
      'должен инициализировать точки маршрута с ошибкой',
      () async {
        // arrange
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
              route: FutureResponse.fail(NO_INTERNET),
            )
          ]),
        );
        verify(repo.calculatePathForRoute(route));
      },
    );

    test(
      'должен инициализировать точки маршрута успешно',
      () async {
        // arrange
        when(repo.calculatePathForRoute(any)).thenAnswer(
          (_) => Future.value(
            FutureResponse.success(MapRoute(10, [cord1, cord2])),
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
              route: FutureResponse.success(MapRoute(10, [cord1, cord2])),
            )
          ]),
        );
        verify(repo.calculatePathForRoute(route));
      },
    );
  });
}
