import 'package:city_go/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'должен создать пользователя InApp из json фабрики',
    () async {
      var json = {
        User.USER_NAME : 'Васян',
        User.USER_TYPE: UserType.InApp.index,
        InAppUser.ACCESS_TOKEN: 'someAccessToken',
      };
      // act
      var user = UserFactory.instance.fromJson(json);

      // assert
      expect(user.runtimeType, InAppUser);
      expect(user.userName, json[User.USER_NAME]);
      expect(user.type, UserType.InApp);
      expect((user as InAppUser).accessToken, json[InAppUser.ACCESS_TOKEN]);
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
}