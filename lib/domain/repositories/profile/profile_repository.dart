import 'package:city_go/domain/entities/profile/profile.dart';

/// Абстрактный репозиторий профиля, который позволяет читать с диска или сохранять
/// профиль на диск
abstract class ProfileRepository {
  /// Читает профиль из хранилища
  Future<Profile> readProfile();

  /// Сохраняет профиль в хранилище
  Future<void> saveProfile(Profile profile);
}