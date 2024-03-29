import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/settings.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/profile/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'profile_storage_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  final user = InAppUser(userName: 'Вася', accessToken: 'token', userId: 1);
  final user2 = InAppUser(userName: 'Петя', accessToken: 'token2', userId: 2);
  final settings = Settings(displayNotification: false);

  late MockProfileRepository repository;
  late ProfileStorage storage;

  setUp(() {
    repository = MockProfileRepository();
    storage = ProfileStorageImpl(repository: repository);
  });

  test(
    'должен инициализировать хранилище профилем',
    () async {
      // arrange
      var p = Profile(user: user, settings: settings);
      when(repository.readProfile()).thenAnswer((_) => Future.value(p));

      // act
      var profile = await storage.initStorage();

      // assert
      verify(repository.readProfile());
      expect(profile, p);
      expect(storage.profile, p);
    },
  );

  group('updateProfile', () {
    test(
      'должен обновить профиль новым пользователем',
      () async {
        // arrange
        var p = Profile(user: user, settings: settings);
        when(repository.readProfile()).thenAnswer((_) => Future.value(p));
        when(repository.saveProfile(any)).thenAnswer((_) => Future.value());

        // act
        await storage.initStorage();
        var profile = await storage.updateProfile(user: user2);

        // assert
        verify(
            repository.saveProfile(Profile(user: user2, settings: settings)));
        expect(profile.user, user2);
        expect(profile.settings, settings);
        expect(storage.profile, profile);
      },
    );

    test(
      'должен обновить профиль новыми настрйоками',
      () async {
        // arrange
        var p = Profile(user: user, settings: settings);
        when(repository.readProfile()).thenAnswer((_) => Future.value(p));
        when(repository.saveProfile(any)).thenAnswer((_) => Future.value());

        // act
        await storage.initStorage();
        var profile = await storage.updateProfile(settings: Settings());

        // assert
        verify(
            repository.saveProfile(Profile(user: user, settings: Settings())));
        expect(profile.user, user);
        expect(profile.settings, Settings());
        expect(storage.profile, profile);
      },
    );
  });

  group('clearFields', () {
    test(
      'должен очистить информацию о пользователе',
      () async {
        // arrange
        var p = Profile(user: user, settings: settings);
        when(repository.readProfile()).thenAnswer((_) => Future.value(p));
        when(repository.saveProfile(any)).thenAnswer((_) => Future.value());

        // act
        await storage.initStorage();
        var profile = await storage.clearField(user: true);

        // assert
        verify(repository.saveProfile(Profile(settings: settings)));
        expect(profile.user, null);
        expect(profile.settings, settings);
        expect(storage.profile, profile);
      },
    );

    test(
      'должен очистить информацию о настройках и привести их к настройкам по-умолчанию',
      () async {
        // arrange
        var p = Profile(user: user, settings: settings);
        when(repository.readProfile()).thenAnswer((_) => Future.value(p));
        when(repository.saveProfile(any)).thenAnswer((_) => Future.value());

        // act
        await storage.initStorage();
        var profile = await storage.clearField(settings: true);

        // assert
        verify(
            repository.saveProfile(Profile(user: user, settings: Settings())));
        expect(profile.user, user);
        expect(profile.settings, Settings());
        expect(storage.profile, profile);
      },
    );
  });
}
