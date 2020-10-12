import 'package:city_go/app/widgets/route_list/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:city_go/domain/repositories/routes/route_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRouteRepo extends Mock implements RouteRepository {}

class MockProfileStorage extends Mock implements ProfileStorage {}

void main() {
  final user = InAppUser(userName: 'name', accessToken: 'token');
  final route = RouteClipped(
    123,
    'Some title',
    2.1,
    '/src/image.jpg',
    3.3,
  );
  MockRouteRepo repository;
  MockProfileStorage storage;
  // ignore: close_sinks
  RouteListBloc bloc;

  setUp(() {
    repository = MockRouteRepo();
    storage = MockProfileStorage();
    bloc = RouteListBloc(repository: repository, storage: storage);
  });

  test(
    'должен инициализироваться с начальным состоянием',
    () async {
      // assert
      expect(bloc.state, RouteListBlocDisplayState([], false));
    },
  );

  group('RouteListDownloadEvent', () {
    test(
      'должен вернуть состояние с кодом ошибки, что пользователь не авторизован',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile());

        // act
        bloc.add(RouteListDownloadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteListBlocLoadingState([]),
            RouteListBlocDisplayState([], true, USER_NOT_AUTH),
          ]),
        );
        verify(storage.profile);
      },
    );

    test(
      'должен вернуть состояние с кодом ошибки, что нет интернета',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getRoutes(
              token: anyNamed('token'), offset: anyNamed('offset')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.fail(NO_INTERNET)),
        );

        // act
        bloc.add(RouteListDownloadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteListBlocLoadingState([]),
            RouteListBlocDisplayState([], true, NO_INTERNET),
          ]),
        );
        verify(repository.getRoutes(token: user.accessToken, offset: 0));
      },
    );

    test(
      'должен загрузить данные с флагом isEndOfList=false',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getRoutes(
              token: anyNamed('token'), offset: anyNamed('offset')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([route])),
        );

        // act
        bloc.add(RouteListDownloadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteListBlocLoadingState([route]),
            RouteListBlocDisplayState([route], false),
          ]),
        );
        verify(repository.getRoutes(token: user.accessToken, offset: 0));
      },
    );

    test(
      'должен загрузить данные но с пустым списком',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getRoutes(
              token: anyNamed('token'), offset: anyNamed('offset')),
        ).thenAnswer(
          (_) => Future.value(FutureResponse.success([])),
        );

        // act
        bloc.add(RouteListDownloadEvent());

        // assert
        await expectLater(
          bloc,
          emitsInOrder([
            RouteListBlocLoadingState([]),
            RouteListBlocDisplayState([], true),
          ]),
        );
        verify(repository.getRoutes(token: user.accessToken, offset: 0));
      },
    );
  });
}
