import 'package:city_go/domain/entities/profile/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'должен создать настройки по-умолчанию, если json отсутствует',
    () async {
      // act
      var settings = Settings.fromJson(null);

      // assert
      expect(settings.displayNotification, true);
      // Дополнительная проверка, которая включает в себя проверку всех полей.
      // Эта проверка должна обновляться при расширении настроек
      expect(settings.toJson(), equals({Settings.DISPLAY_NOTIFICATION: true}));
    },
  );

  test(
    'должен создать объект из json',
    () async {
      // arrange
      var json = {Settings.DISPLAY_NOTIFICATION: false};

      // act
      var settings = Settings.fromJson(json);

      // assert
      expect(settings.displayNotification, json[Settings.DISPLAY_NOTIFICATION]);
      // Дополнительная проверка, которая включает в себя проверку всех полей.
      // Эта проверка должна обновляться при расширении настроек
      expect(settings.toJson(), equals(json));
    },
  );

  test(
    'должен создать объект по-умолчанию через конструктор',
    () async {
      // act
      var settings = Settings();

      // assert
      expect(settings.displayNotification, true);
      // Дополнительная проверка, которая включает в себя проверку всех полей.
      // Эта проверка должна обновляться при расширении настроек
      expect(settings.toJson(), equals({Settings.DISPLAY_NOTIFICATION: true}));
    },
  );
}
