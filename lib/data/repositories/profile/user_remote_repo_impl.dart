import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/profile/user_remote_repository.dart';
import 'package:dio/dio.dart';

export 'package:city_go/domain/repositories/profile/user_remote_repository.dart';

/// Реализация репозитория, который отправляет данные на удалённый сервер
class UserRemoteRepositoryImpl extends UserRemoteRepository {
  final HttpClient client;
  final NetworkChecker checker;

  UserRemoteRepositoryImpl(this.client, this.checker);

  /// Создает нового пользователя по возможности, а затем делает login
  @override
  Future<FutureResponse<User>> authNewUser(
      String userName, String password) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    try {
      await client.post(
        '/auth/users/',
        data: {'username': userName, 'password': password},
      );

      return await logInUser(userName, password);
    } on DioError catch (e) {
      return FutureResponse.fail(
        handleDioError(e, overrideData: {400: LOGIN_ALREADY_USED}),
      );
    } catch (e) {
      return FutureResponse.fail(UNEXPECTED_ERROR);
    }
  }

  @override
  Future<FutureResponse<User>> authWithExternalService(
      ExternalUser user) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    try {
      final response = await client.post(
        '/auth/convert-token/',
        data: {
          'grant_type': 'convert_token',
          'backend': user.type.backend,
          'token': user.accessToken,
          'client_id': 'RutIxLet0pl9bALbEJW78afIVg2EQldaJoahxck0',
        },
      );

      return FutureResponse.success(
        user.updateUserData(accessToken: response.data['auth_token']),
      );
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(UNEXPECTED_ERROR);
    }
  }

  @override
  Future<FutureResponse<User>> logInUser(
      String userName, String password) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    try {
      final response = await client.post(
        '/auth/token/login/',
        data: {'username': userName, 'password': password},
      );

      return FutureResponse.success(
        InAppUser(
          userName: userName,
          accessToken: response.data['auth_token'],
        ),
      );
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(UNEXPECTED_ERROR);
    }
  }
}
