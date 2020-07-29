import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/settings.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/profile/profile_repository.dart';
import 'package:meta/meta.dart';

/// Абстрактное хранилище профиля. Должно быть singleton и инициализироваться
/// в самом начале запуска приложения.
/// Для получения данных профиля, необходимо обратиться к Сервис-локатору.
/// ```
/// sl<>(ProfileStorage).profile;
/// ```
abstract class ProfileStorage {
  Profile get profile;

  /// Инициализация хранилища путём загрузки данных с диска.
  /// Возвращает прочитанный объект профиля
  Future<Profile> initStorage();

  /// Обновление профиля с новыми данными пользователя или настроек.
  /// Возвращает новый созданный объект профиля.
  /// !Перед использованием профиль должен быть инициализирован вызовом [initStorage]
  Future<Profile> updateProfile({User user, Settings settings});

  /// Очистка полей (приведение к полям по-умолчанию).
  /// Если какое-то поле нужно очистить, то должно быть передано значение true
  Future<Profile> clearField({bool user, bool settings});
}

/// Реализация хранилища профиля
class ProfileStorageImpl extends ProfileStorage {
  final ProfileRepository repository;

  ProfileStorageImpl({@required this.repository});

  Profile _profile;

  @override
  Profile get profile => _profile;

  @override
  Future<Profile> initStorage() async {
    var p = await repository.readProfile();
    _profile = p;
    return _profile;
  }

  @override
  Future<Profile> updateProfile({User user, Settings settings}) async {
    _profile = _profile.copyWith(user: user, settings: settings);
    await repository.saveProfile(_profile);
    return _profile;
  }

  @override
  Future<Profile> clearField({bool user = false, bool settings = false}) async {
    _profile = _profile.clearField(user: user, settings: settings);
    await repository.saveProfile(_profile);
    return _profile;
  }
}
