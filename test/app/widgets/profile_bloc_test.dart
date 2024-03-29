import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/profile/user_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'profile_bloc_test.mocks.dart';

@GenerateMocks([UserRemoteRepository, ProfileStorage])
void main() {
  final userName = 'Вася';
  final password = 'password';
  final defaultUser =
      InAppUser(userName: userName, accessToken: 'token', userId: 1);
  final vkUserComplete =
      VKUser(userName: 'Вася', externalToken: 'vkToken', accessToken: 'token');
  final vkUserNotComplete = VKUser(userName: 'Вася', externalToken: 'vkToken');

  late MockProfileStorage storage;
  late MockUserRemoteRepository repository;

  // ignore: close_sinks
  late ProfileBloc bloc;

  void setUpAuthUser() {
    storage = MockProfileStorage();
    repository = MockUserRemoteRepository();
    when(storage.profile).thenReturn(Profile(user: defaultUser));
    bloc = ProfileBloc(storage: storage, repository: repository);
  }

  void setUpNotAuthUser() {
    storage = MockProfileStorage();
    repository = MockUserRemoteRepository();
    when(storage.profile).thenReturn(Profile());
    bloc = ProfileBloc(storage: storage, repository: repository);
  }

  group('constructor', () {
    test(
      'должен инициализировать блок с состоянием, что пользователь авторизован',
      () async {
        // arrange
        setUpAuthUser();
        // assert
        verify(storage.profile);
        expect(
            bloc.state, ProfileAuthenticatedState(Profile(user: defaultUser)));
      },
    );

    test(
      'должен инициализировать блок с состоянием, что пользователь НЕ авторизован',
      () async {
        // arrange
        setUpNotAuthUser();
        // assert
        verify(storage.profile);
        expect(bloc.state, ProfileNeedAuthState());
      },
    );
  });

  group('authEvents', () {
    test(
      'должен совершить регистрацию через внешний источник',
      () async {
        // arrange
        setUpNotAuthUser();
        when(repository.authWithExternalService(any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(vkUserComplete)),
        );
        when(storage.updateProfile(user: anyNamed('user')))
            .thenAnswer((_) => Future.value(Profile(user: vkUserComplete)));

        // act
        bloc.add(ProfileAuthExternalEvent(vkUserNotComplete));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder(
              [ProfileAuthenticatedState(Profile(user: vkUserComplete))]),
        );
        verify(repository.authWithExternalService(vkUserNotComplete));
        verify(storage.updateProfile(user: vkUserComplete));
      },
    );
    test(
      'должен совершить регистрацию через внешний источник, но получить ошибку',
      () async {
        // arrange
        setUpNotAuthUser();
        when(repository.authWithExternalService(any)).thenAnswer(
          (_) => Future.value(FutureResponse.fail(NO_INTERNET)),
        );

        // act
        bloc.add(ProfileAuthExternalEvent(vkUserNotComplete));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([ProfileNeedAuthState(errorCode: NO_INTERNET)]),
        );
        verify(repository.authWithExternalService(vkUserNotComplete));
        verifyNever(storage.updateProfile(user: anyNamed('user')));
      },
    );

    test(
      'должен совершить регистрацию через внутренний сервер',
      () async {
        // arrange
        setUpNotAuthUser();
        when(repository.authNewUser(any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(defaultUser)),
        );
        when(storage.updateProfile(user: anyNamed('user')))
            .thenAnswer((_) => Future.value(Profile(user: defaultUser)));

        // act
        bloc.add(ProfileAuthInternalEvent(userName, password));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([ProfileAuthenticatedState(Profile(user: defaultUser))]),
        );
        verify(repository.authNewUser(userName, password));
        verify(storage.updateProfile(user: defaultUser));
      },
    );

    test(
      'должен совершить регистрацию через внутренний сервер, но получить ошибку',
      () async {
        // arrange
        setUpNotAuthUser();
        when(repository.authNewUser(any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.fail(NO_INTERNET)),
        );

        // act
        bloc.add(ProfileAuthInternalEvent(userName, password));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([ProfileNeedAuthState(errorCode: NO_INTERNET)]),
        );
        verify(repository.authNewUser(userName, password));
        verifyNever(storage.updateProfile(user: anyNamed('user')));
      },
    );
  });

  group('loginEvent', () {
    test(
      'должен авторизоваться с ошибкой',
      () async {
        // arrange
        setUpNotAuthUser();
        when(repository.logInUser(any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.fail(NO_INTERNET)),
        );

        // act
        bloc.add(ProfileLogInEvent(userName, password));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([ProfileNeedLoginState(errorCode: NO_INTERNET)]),
        );
        verify(repository.logInUser(userName, password));
        verifyNever(storage.updateProfile(user: anyNamed('user')));
      },
    );

    test(
      'должен авторизоваться успешно',
      () async {
        // arrange
        setUpNotAuthUser();
        when(repository.logInUser(any, any)).thenAnswer(
          (_) => Future.value(FutureResponse.success(defaultUser)),
        );
        when(storage.updateProfile(user: anyNamed('user'))).thenAnswer(
          (_) => Future.value(Profile(user: defaultUser)),
        );

        // act
        bloc.add(ProfileLogInEvent(userName, password));

        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([ProfileAuthenticatedState(Profile(user: defaultUser))]),
        );
        verify(repository.logInUser(userName, password));
        verify(storage.updateProfile(user: defaultUser));
      },
    );
  });

  test(
    '''должен переместить на состояние входа, когда пользователь нажимает кнопку
    "есть аккаунт"''',
    () async {
      // act
      bloc.add(ProfileGoToLoginEvent());

      // assert
      await expectLater(bloc.stream, emitsInOrder([ProfileNeedLoginState()]));
    },
  );

  test(
    '''должен перенаправить на состояние авторизации, когда нажимается логаут, 
    а также стереть информацию о пользователе''',
    () async {
      // arrange
      when(storage.clearField(user: anyNamed('user'))).thenAnswer(
        (_) => Future.value(Profile()),
      );

      // act
      bloc.add(ProfileLogoutEvent());

      // assert
      await expectLater(
        bloc.stream,
        emitsInOrder([ProfileNeedAuthState()]),
      );
      verify(storage.clearField(user: true));
    },
  );
}
