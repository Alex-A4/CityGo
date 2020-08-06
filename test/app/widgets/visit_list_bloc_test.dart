import 'package:city_go/app/widgets/visit_place_list/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPlaceRepository extends Mock implements PlaceRepository {}

class MockProfileStorage extends Mock implements ProfileStorage {}

void main() {
  final type = PlaceType.Museums;
  final user = InAppUser(userName: 'name', accessToken: 'token');
  final place1 = ClippedVisitPlace(10, 'name1', '10:00-18:00', 3.3);
  final place2 = ClippedVisitPlace(12, 'name2', '09:00-18:00', 4.2);

  final defaultSort = PlaceSortType.Proximity;
  final changedSort = PlaceSortType.Random;

  MockPlaceRepository repository;
  MockProfileStorage storage;
  // ignore: close_sinks
  VisitListBloc bloc;

  setUp(() {
    repository = MockPlaceRepository();
    storage = MockProfileStorage();
    bloc = VisitListBloc(repository: repository, type: type, storage: storage);
  });

  test(
    'должен инициализировать состояние с типом места, который передан в констркутор',
    () async {
      // assert
      expect(bloc.state,
          VisitListBlocPlaceState(PlaceType.Museums, [], defaultSort, false));
    },
  );

  group('VisitListBlocLoadPlacesEvent', () {
    test(
      'должен завершить загрузку с ошибкой, что нет пользователя',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile());

        // act
        bloc.add(VisitListBlocLoadPlacesEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [], defaultSort),
            VisitListBlocPlaceState(type, [], defaultSort, true, USER_NOT_AUTH),
          ]),
        );
        verify(storage.profile);
        verifyNever(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType')),
        );
      },
    );

    test(
      'должен завершить загрузку с ошибкой нет интернета',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.fail(NO_INTERNET)),
        );

        // act
        bloc.add(VisitListBlocLoadPlacesEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [], defaultSort),
            VisitListBlocPlaceState(type, [], defaultSort, true, NO_INTERNET),
          ]),
        );
        verify(storage.profile);
        verify(repository.getPlaces(
            placeType: type,
            token: user.accessToken,
            offset: 0,
            sortType: defaultSort));
      },
    );

    test(
      'должен завершиться с успехом',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([place1, place2])),
        );

        // act
        bloc.add(VisitListBlocLoadPlacesEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [place1, place2], defaultSort),
            VisitListBlocPlaceState(type, [place1, place2], defaultSort, false),
          ]),
        );
        verify(storage.profile);
        verify(repository.getPlaces(
            placeType: type,
            token: user.accessToken,
            offset: 0,
            sortType: defaultSort));
      },
    );

    test(
      'должен загрузить сперва один раз, а потом догрузить список еще раз',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([place1])),
        );

        // act
        bloc.add(VisitListBlocLoadPlacesEvent());
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [place1], defaultSort),
            VisitListBlocPlaceState(type, [place1], defaultSort, false),
          ]),
        );
        bloc.add(VisitListBlocLoadPlacesEvent());
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [place1, place1], defaultSort),
            VisitListBlocPlaceState(type, [place1, place1], defaultSort, false),
          ]),
        );

        // assert
        verify(storage.profile);
        verify(repository.getPlaces(
            placeType: type,
            token: user.accessToken,
            offset: 0,
            sortType: defaultSort));
        verify(repository.getPlaces(
            placeType: type,
            token: user.accessToken,
            offset: 1,
            sortType: defaultSort));
      },
    );

    test(
      'флаг isEndOfList должен стать true, если репозиторий вернул пустой список',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([])),
        );

        // act
        bloc.add(VisitListBlocLoadPlacesEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [], defaultSort),
            VisitListBlocPlaceState(type, [], defaultSort, true),
          ]),
        );
        verify(storage.profile);
        verify(repository.getPlaces(
          placeType: type,
          token: user.accessToken,
          offset: 0,
          sortType: defaultSort,
        ));
      },
    );
  });

  group('VisitListBlocChangeSortType', () {
    test(
      'должен поменять локальную переменную и сделать запрос на сервер',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([place1])),
        );
        expect(bloc.sortType, defaultSort);

        // act
        bloc.add(VisitListBlocChangeSortType(changedSort));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [place1], changedSort),
            VisitListBlocPlaceState(type, [place1], changedSort, false),
          ]),
        );
        expect(bloc.sortType, changedSort);
        verify(repository.getPlaces(
          placeType: type,
          token: user.accessToken,
          offset: 0,
          sortType: changedSort,
        ));
      },
    );

    test(
      'не должен вызывать данные, если входящий тип не изменился',
      () async {
        // arrange
        expect(bloc.sortType, defaultSort);

        // act
        bloc.add(VisitListBlocChangeSortType(defaultSort));

        // assert
        await expectLater(
          bloc,
          emitsInOrder([]),
        );

        expect(bloc.sortType, defaultSort);
        verifyNever(storage.profile);
        verifyNever(repository.getPlaces(
            placeType: anyNamed('placeType'),
            token: anyNamed('token'),
            offset: anyNamed('offset'),
            sortType: anyNamed('sortType')));
      },
    );
  });
}
