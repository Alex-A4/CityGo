import 'package:city_go/domain/entities/profile/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'должен создать пользователя InApp из json фабрики',
    () async {
      var json = {
        User.USER_NAME: 'Васян',
        User.USER_TYPE: UserType.InApp.index,
        User.ACCESS_TOKEN: 'someAccessToken',
      };
      // act
      var user = UserFactory.instance.fromJson(json);

      // assert
      expect(user.runtimeType, InAppUser);
      expect(user.userName, json[User.USER_NAME]);
      expect(user.type, UserType.InApp);
      expect((user as InAppUser).accessToken, json[User.ACCESS_TOKEN]);
    },
  );

  test(
    'должен вернуть null, если json не передан',
    () async {
      // act
      var user = UserFactory.instance.fromJson(null);

      // assert
      expect(user, null);
    },
  );

  test(
    'должен конвертировать пользователя в JSON',
    () async {
      // arrange
      var user = InAppUser(
        userName: 'Вася',
        accessToken: 'token',
      );

      // act
      var json = user.toJson();

      // assert
      expect(json[User.USER_TYPE], user.type.index);
      expect(json[User.USER_NAME], user.userName);
      expect(json[User.ACCESS_TOKEN], user.accessToken);
    },
  );
}
