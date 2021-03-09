import 'package:city_go/domain/entities/profile/settings.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Модель профиля, содержит информацию о пользователе, уведомлениях, языке и
/// прочей информации, которая связана с профилем
@immutable
class Profile extends Equatable {
  /// Объект пользователя, который может быть не инициализирован
  static const USER = 'user';
  final User? user;

  /// Объект настроек. Если при запуске приложения, нет данных о настройках, они
  /// должны инициализироваться значениями по-умолчанию
  static const SETTINGS = 'settings';
  final Settings settings;

  Profile({this.user, this.settings = const Settings()});

  /// Фабрика по созданию профиля из JSON объекта
  factory Profile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Profile.empty();

    return Profile(
      user: UserFactory.instance.fromJson(json[USER]),
      settings: Settings.fromJson(json[SETTINGS]),
    );
  }

  factory Profile.empty() => Profile(settings: Settings());

  /// Метод для создания нового объекта.
  /// Если входные значения не переданы (равны null), то будет использоваться
  /// имеющееся значение.
  Profile copyWith({User? user, Settings? settings}) {
    return Profile(
      user: user ?? this.user,
      settings: settings ?? this.settings,
    );
  }

  /// Метод для очистки какого-либо поля.
  /// В случае настроек, это приведение их к настройкам по-умолчанию.
  Profile clearField({bool user = false, bool settings = false}) {
    return Profile(
      user: user ? null : this.user,
      settings: settings ? Settings() : this.settings,
    );
  }

  /// Метод для конвертации объекта профиля в JSON формат.
  /// Поскольку пользователь может отсутствовать, его значение может быть
  /// равно null.
  Map<String, dynamic> toJson() => {
        USER: user?.toJson(),
        SETTINGS: settings.toJson(),
      };

  @override
  List<Object?> get props => [user, settings];
}
