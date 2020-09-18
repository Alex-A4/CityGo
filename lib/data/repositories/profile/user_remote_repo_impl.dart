import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/profile/user_remote_repository.dart';

export 'package:city_go/domain/repositories/profile/user_remote_repository.dart';

/// Реализация репозитория, который отправляет данные на удалённый сервер
class UserRemoteRepositoryImpl extends UserRemoteRepository {
  final HttpClient client;
  final NetworkChecker checker;

  UserRemoteRepositoryImpl(this.client, this.checker);

  @override
  Future<FutureResponse<User>> authNewUser(
      String userName, String password) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    return FutureResponse.fail(NO_INTERNET);
  }

  @override
  Future<FutureResponse<User>> authWithExternalService(User user) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    return FutureResponse.fail(NO_INTERNET);
  }

  @override
  Future<FutureResponse<User>> logInUser(
      String userName, String password) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    return FutureResponse.fail(NO_INTERNET);
  }
}
