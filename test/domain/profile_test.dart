import 'package:city_go/domain/entities/profile.dart';
import 'package:city_go/domain/entities/settings.dart';
import 'package:city_go/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final user = InAppUser(
    userName: 'Вася',
    accessToken: 'token',
  );
  final settings = Settings(displayNotification: false);

  group('fromJson', () {
    test(
      'должен создать профиль по-умолчанию, если json не передан',
      () async {
        // act
        var profile = Profile.fromJson(null);

        // assert
        expect(profile.user, null);
        expect(profile.settings, Settings());
        expect(profile, Profile());
      },
    );

    test(
      'должен создать профиль из JSON объекта, где пользователь отсутствует',
      () async {
        // arrange
        var json = {Profile.SETTINGS: settings.toJson()};

        // act
        var profile = Profile.fromJson(json);

        // assert
        expect(profile.user, null);
        expect(profile.settings, settings);
      },
    );

    test(
      'должен создать профиль со всеми данными',
      () async {
        // arrange
        var json = {
          Profile.SETTINGS: settings.toJson(),
          Profile.USER: user.toJson()
        };

        // act
        var profile = Profile.fromJson(json);

        // assert
        expect(profile.user, user);
        expect(profile.settings, settings);
      },
    );
  });

  group('toJson', () {
    test(
      'должен конвертировать профиль в JSON',
      () async {
        // arrange
        var json = {
          Profile.SETTINGS: settings.toJson(),
          Profile.USER: user.toJson()
        };

        // act
        var profile = Profile(settings: settings, user: user);

        // assert
        expect(profile.toJson(), json);
      },
    );

    test(
      'должен конвертировать в json, если нет пользователя',
      () async {
        // arrange
        var profile = Profile(settings: settings);

        // act
        var json = profile.toJson();

        // assert
        expect(json[Profile.USER], null);
        expect(json[Profile.SETTINGS], settings.toJson());
      },
    );
  });

  group('copyWith', () {
    test(
      'должен скопировать профиль с новыми настройками',
      () async {
        // act
        var profile = Profile();
        // assert
        expect(profile.settings, isNot(settings));
        profile = profile.copyWith(settings: settings);
        expect(profile.settings, equals(settings));
      },
    );

    test(
      'должен скопировать профиль с новым пользователем',
      () async {
        // arrange
        var profile = Profile();

        // act
        profile = profile.copyWith(user: user);

        // assert
        expect(profile.user, equals(user));
      },
    );
  });

  group('clearField', () {
    test(
      'должен очистить поле пользователя',
      () async {
        // arrange
        var profile = Profile(user: user);
        expect(profile.user, isNotNull);

        // act
        profile = profile.clearField(user: true);

        // assert
        expect(profile.user, null);
      },
    );

    test(
      'должен привести настройки к настройкам по-умолчанию',
      () async {
        // arrange
        var profile = Profile(settings: settings);

        // act
        profile = profile.clearField(settings: true);

        // assert
        expect(profile.settings, equals(Settings()));
      },
    );
  });
}
