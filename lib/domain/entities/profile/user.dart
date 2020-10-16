import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Модель пользователя, описывает имя и дополнительные параметры
/// Сам пользователь является абстрактным, поскольку могут быть разные его
/// реализации (ВК, Гугл, кастомный, итд)
abstract class User extends Equatable {
  static const USER_TYPE = 'userType';
  final UserType type;

  /// По-умолчанию все пользователи имеют имя, все остальные параметры зависят
  /// от реализации
  static const USER_NAME = 'userName';
  final String userName;

  /// Токен доступа к серверу
  static const ACCESS_TOKEN = 'accessToken';
  final String accessToken;

  User(this.userName, this.type, this.accessToken);

  /// Метод для конвертации пользователя в JSON формат.
  /// Классы-наследники должны переопределить этот метод и дополнить его реализацию.
  Map<String, dynamic> toJson() => {
        USER_NAME: userName,
        USER_TYPE: type.index,
        ACCESS_TOKEN: accessToken,
      };
}

/// Тип пользователя, который определяет его реальную реализацию
enum UserType { InApp, Google, VK, Instagram }

extension UserTypeData on UserType {
  String get backend {
    switch (this) {
      case UserType.InApp:
        return null;
      case UserType.Google:
        return 'google';
      case UserType.VK:
        return 'vk-oauth2';
      case UserType.Instagram:
        return 'instagram';
      default:
        return null;
    }
  }
}

/// Класс пользователя, который зарегистрировался в приложении
class InAppUser extends User {
  InAppUser({
    @required String userName,
    @required String accessToken,
  }) : super(userName, UserType.InApp, accessToken);

  factory InAppUser.fromJson(Map<String, dynamic> json) {
    return InAppUser(
      userName: json[User.USER_NAME],
      accessToken: json[User.ACCESS_TOKEN],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  List<Object> get props => [userName, type, accessToken];
}

abstract class ExternalUser extends User {
  static const EXTERNAL_TOKEN = 'externalToken';

  ExternalUser updateUserData(
      {String userName, String accessToken, String externalToken});

  String get externalToken;

  ExternalUser(String userName, UserType type, String accessToken)
      : super(userName, type, accessToken);

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json[EXTERNAL_TOKEN] = externalToken;
    return json;
  }
}

class VKUser extends ExternalUser {
  final String externalToken;

  /// Токен авторизации на сервере, инициализируется после отправки запроса
  VKUser({
    @required this.externalToken,
    String userName,
    String accessToken,
  }) : super(userName, UserType.VK, accessToken);

  factory VKUser.fromJson(Map<String, dynamic> json) {
    return VKUser(
      userName: json[User.USER_NAME],
      externalToken: json[ExternalUser.EXTERNAL_TOKEN],
      accessToken: json[User.ACCESS_TOKEN],
    );
  }

  @override
  List<Object> get props => [userName, type, accessToken, externalToken];

  @override
  ExternalUser updateUserData({
    String userName,
    String accessToken,
    String externalToken,
  }) =>
      VKUser(
        externalToken: externalToken ?? this.externalToken,
        accessToken: accessToken ?? this.accessToken,
        userName: userName ?? this.userName,
      );
}

/// Абстрактная фабрика по созданию пользователя из JSON формата
abstract class UserFactory {
  /// Статический объект фабрики, при необходимости может быть переопределен
  /// для тестов
  static UserFactory instance = DefaultUserFactory();

  /// Создать пользователя из JSON объекта
  User fromJson(Map<String, dynamic> json);
}

/// Фабрика пользователя по-умолчанию, создаёт
class DefaultUserFactory extends UserFactory {
  @override
  User fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    var type = UserType.values[json[User.USER_TYPE]];
    switch (type) {
      case UserType.InApp:
        return InAppUser.fromJson(json);
      case UserType.Google:
        throw UnimplementedError();
      case UserType.VK:
        return VKUser.fromJson(json);
      case UserType.Instagram:
        throw UnimplementedError();
    }

    return null;
  }
}
