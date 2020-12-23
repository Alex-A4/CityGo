import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/entities/routes/route_cord.dart';
import 'package:city_go/domain/repositories/routes/route_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRouteRepo extends Mock implements RouteRepository {}

class MockProfileStorage extends Mock implements ProfileStorage {}

void main() {
  final user = InAppUser(userName: 'name', accessToken: 'token', userId: 1);
  final id = 123;
  final route = Route(
    id,
    'Some title',
    'Some description',
    3.1,
    2.1,
    '1 час, 5 минут',
    'Some general info',
    '/src/someMP.mp3',
    [
      FullVisitPlace.fromJson({
        'id': 10,
        'name': 'Место',
        'workTime': 'пн-вт, 9:00-18:00',
        'rating': 4.1,
        'address': 'Улица Пушкина',
        'website': 'http://sdfsd.ru',
        'type': 1,
        'general': 'Какая-то инфа',
        'cords': {
          'lat': 23.1252,
          'lng': 52.2512,
        }
      }),
    ],
    [
      RouteCord.fromJson({
        'lat': 41.512,
        'lng': 41.42,
        'order': 1,
      }),
    ],
    '/src/image.jpg',
  );

  MockRouteRepo repository;
  MockProfileStorage storage;
  // ignore: close_sinks
  RouteSingleBloc bloc;

  setUp(() {
    repository = MockRouteRepo();
    storage = MockProfileStorage();
    bloc = RouteSingleBloc(repository: repository, storage: storage, id: id);
  });

  test(
    'должен инициализироваться с начальным состоянием',
    () async {
      // assert
      expect(bloc.state, RouteSingleBlocEmptyState());
    },
  );

  group('RouteSingleBlocLoadEvent', () {
    test(
      'должен завершиться с ошибкой, что пользователь не авторизован',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile());

        // act
        bloc.add(RouteSingleBlocLoadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([RouteSingleBlocDataState(null, USER_NOT_AUTH)]),
        );
        verify(storage.profile);
      },
    );

    test(
      'должен завершиться с ошибкой, что нет интернета',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(repository.getRoute(id: anyNamed('id'), token: anyNamed('token')))
            .thenAnswer(
          (_) => Future.value(FutureResponse.fail(NO_INTERNET)),
        );

        // act
        bloc.add(RouteSingleBlocLoadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([RouteSingleBlocDataState(null, NO_INTERNET)]),
        );
        verify(storage.profile);
        verify(repository.getRoute(id: id, token: user.accessToken));
      },
    );

    test(
      'должен вернуть корректные данные маршрута',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(repository.getRoute(id: anyNamed('id'), token: anyNamed('token')))
            .thenAnswer(
          (_) => Future.value(FutureResponse.success(route)),
        );

        // act
        bloc.add(RouteSingleBlocLoadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([RouteSingleBlocDataState(route)]),
        );
        verify(storage.profile);
        verify(repository.getRoute(id: id, token: user.accessToken));
      },
    );
  });
}
