import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/user.dart';

export 'package:city_go/domain/entities/future_response.dart';

/// Абстрактный класс репозитория, который позволяет авторизоваться/зарегистрироваться
/// пользователю с использованием сервера.
abstract class UserRemoteRepository {
  /// Авторизация пользователя через внутренний сервер
  Future<FutureResponse<User>> authNewUser(String userName, String password);

  /// Авторизация пользователя через внешние источники.
  /// Авторизация через внешние источники равносильна входу через источник.
  /// На сервер должны отдаваться данные, а получаться обновленные с
  /// дополнительным токеном.
  Future<FutureResponse<User>> authWithExternalService(User user);

  /// Вход существующего пользователя в аккаунт на сервере
  Future<FutureResponse<User>> logInUser(String userName, String password);
}
