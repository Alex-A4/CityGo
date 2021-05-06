import 'package:city_go/app/widgets/visit_place_list/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/lat_lng.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'visit_list_bloc_test.mocks.dart';

@GenerateMocks([PlaceRepository, ProfileStorage, Geolocator])
void main() {
  final type = PlaceType.Museums;
  final logo = ImageSrc('/src/logo.jpg', 'description', 'title');
  final user = InAppUser(userName: 'name', accessToken: 'token', userId: 1);
  final place1 = ClippedVisitPlace(10, PlaceType.Museums, 'name1',
      '10:00-18:00', 3.3, logo.path, LatLng(52.0, 38.0), 'general');
  final place2 = ClippedVisitPlace(12, PlaceType.Museums, 'name2',
      '09:00-18:00', 4.2, logo.path, LatLng(51.5, 37.23), 'general');

  final defaultSort = PlaceSortType.Rating;
  final changedSort = PlaceSortType.Distance;

  late MockPlaceRepository repository;
  late MockProfileStorage storage;
  late MockGeolocator geolocator;
  // ignore: close_sinks
  late VisitListBloc bloc;

  setUp(() {
    repository = MockPlaceRepository();
    storage = MockProfileStorage();
    geolocator = MockGeolocator();
    bloc = VisitListBloc(
      repository: repository,
      type: type,
      storage: storage,
      geolocator: geolocator,
    );
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
          bloc.stream,
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
          bloc.stream,
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
          bloc.stream,
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
          bloc.stream,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [place1], defaultSort),
            VisitListBlocPlaceState(type, [place1], defaultSort, false),
          ]),
        );
        bloc.add(VisitListBlocLoadPlacesEvent());
        await expectLater(
          bloc.stream,
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
          bloc.stream,
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
        final latLng = g.LatLng(57.0, 38.0);
        when(geolocator.getPosition()).thenAnswer((_) => Future.value(latLng));
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType'),
              latLng: anyNamed('latLng')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([place1])),
        );
        expect(bloc.sortType, defaultSort);

        // act
        bloc.add(VisitListBlocChangeSortType(changedSort));

        // assert
        await expectLater(
          bloc.stream,
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
          latLng: latLng,
        ));
      },
    );

    test(
      'должен поменять локальную переменную и не сделать запрос, если геолокация выключена',
      () async {
        // arrange
        when(geolocator.getPosition()).thenThrow(LOCATION_SERVICE_DISABLED);
        when(storage.profile).thenReturn(Profile(user: user));
        expect(bloc.sortType, defaultSort);

        // act
        bloc.add(VisitListBlocChangeSortType(changedSort));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [], changedSort),
            VisitListBlocPlaceState(
                type, [], changedSort, true, LOCATION_SERVICE_DISABLED),
          ]),
        );
        expect(bloc.sortType, changedSort);
        verifyNever(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType'),
              latLng: anyNamed('latLng')),
        );
      },
    );

    test(
      'должен поменять локальную переменную и не сделать запрос, если геолокация заблокирована',
      () async {
        // arrange
        when(geolocator.getPosition()).thenThrow(LOCATION_ACCESS_DENIED);
        when(storage.profile).thenReturn(Profile(user: user));
        expect(bloc.sortType, defaultSort);

        // act
        bloc.add(VisitListBlocChangeSortType(changedSort));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            VisitListBlocPlaceLoadingState(type, [], changedSort),
            VisitListBlocPlaceState(
                type, [], changedSort, true, LOCATION_ACCESS_DENIED),
          ]),
        );
        expect(bloc.sortType, changedSort);
        verifyNever(
          repository.getPlaces(
              placeType: anyNamed('placeType'),
              token: anyNamed('token'),
              offset: anyNamed('offset'),
              sortType: anyNamed('sortType'),
              latLng: anyNamed('latLng')),
        );
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
          bloc.stream,
          emitsInOrder([]),
        );

        expect(bloc.sortType, defaultSort);
        verifyNever(storage.profile);
        verifyNever(repository.getPlaces(
          placeType: anyNamed('placeType'),
          token: anyNamed('token'),
          offset: anyNamed('offset'),
          sortType: anyNamed('sortType'),
        ));
      },
    );
  });
}
