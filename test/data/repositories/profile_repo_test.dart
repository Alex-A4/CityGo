import 'dart:convert';

import 'package:city_go/data/repositories/profile/profile_repository_impl.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/settings.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

void main() {
  final user = InAppUser(userName: 'Вася', accessToken: 'token', userId: 1);
  final settings = Settings(displayNotification: false);

  MockHive hive;
  MockBox box;
  ProfileRepositoryImpl repository;

  setUp(() {
    hive = MockHive();
    box = MockBox();
    repository = ProfileRepositoryImpl(hive: hive);
  });

  group('readProfile', () {
    test(
      'должен вернуть профиль по-умолчанию, если нет данных',
      () async {
        // arrange
        when(hive.openBox(any)).thenAnswer((_) => Future.value(box));
        when(box.get(any)).thenReturn(null);

        // act
        var profile = await repository.readProfile();

        // assert
        verify(hive.openBox(ProfileRepositoryImpl.kProfile));
        verify(box.get(ProfileRepositoryImpl.kProfile));
        expect(profile.user, null);
        expect(profile.settings, Settings());
      },
    );

    test(
      'должен вернуть профиль, прочитанный из хранилища',
      () async {
        var j = {
          Profile.SETTINGS: settings.toJson(),
          Profile.USER: user.toJson(),
        };
        // arrange
        when(hive.openBox(any)).thenAnswer((_) => Future.value(box));
        when(box.get(any)).thenReturn(json.encode(j));

        // act
        var profile = await repository.readProfile();

        // assert
        verify(hive.openBox(ProfileRepositoryImpl.kProfile));
        verify(box.get(ProfileRepositoryImpl.kProfile));
        expect(profile.user, user);
        expect(profile.settings, settings);
      },
    );
  });

  test(
    'должен сохранить профиль в хранилище',
    () async {
      // arrange
      var profile = Profile(settings: settings, user: user);
      when(hive.openBox(any)).thenAnswer((_) => Future.value(box));
      when(box.put(any, any)).thenAnswer((_) => Future.value());

      // act
      await repository.saveProfile(profile);

      // assert
      verify(hive.openBox(ProfileRepositoryImpl.kProfile));
      verify(box.put(
          ProfileRepositoryImpl.kProfile, json.encode(profile.toJson())));
    },
  );
}
