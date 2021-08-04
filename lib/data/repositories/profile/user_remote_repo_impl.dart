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
    String userName,
    String password,
  ) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    try {
      await client.post(
        '/auth/users/',
        data: {'username': userName, 'password': password},
      );

      return await logInUser(userName, password);
    } on DioError catch (e) {
      print(e);
      print(e.response?.data);
      String? mess400;
      if (e.response?.data['username'] != null) mess400 = LOGIN_ALREADY_USED;
      if (e.response?.data['password'] != null) mess400 = PASSWORD_IS_EASY;
      return FutureResponse.fail(
        handleDioError(e, overrideData: {400: mess400}),
      );
    } catch (e) {
      return FutureResponse.fail(UNEXPECTED_ERROR);
    }
  }

  @override
  Future<FutureResponse<User>> authWithExternalService(
    ExternalUser user,
  ) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    try {
      final response = await client.post(
        '/auth/oauth/',
        data: {
          'service': user.type.backend,
          'code': user.externalToken,
        },
      );
      final idResponse = await client.get(
        '/auth/users/me/',
        options: Options(
          headers: {'Authorization': 'Token ${response.data['auth_token']}'},
          responseType: ResponseType.json,
        ),
      );

      return FutureResponse.success(
        user.updateUserData(
          accessToken: response.data['auth_token'],
          userId: idResponse.data['id'],
        ),
      );
    } on DioError catch (e) {
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(UNEXPECTED_ERROR);
    }
  }

  @override
  Future<FutureResponse<User>> logInUser(
    String userName,
    String password,
  ) async {
    if (!await checker.hasInternet) return FutureResponse.fail(NO_INTERNET);

    try {
      final response = await client.post(
        '/auth/token/login/',
        data: {'username': userName, 'password': password},
        options: Options(responseType: ResponseType.json),
      );
      final idResponse = await client.get(
        '/auth/users/me/',
        options: Options(
          headers: {'Authorization': 'Token ${response.data['auth_token']}'},
          responseType: ResponseType.json,
        ),
      );

      return FutureResponse.success(
        InAppUser(
          userName: userName,
          accessToken: response.data['auth_token'],
          userId: idResponse.data['id'],
        ),
      );
    } on DioError catch (e) {
      print(e);
      print(e.response?.data);
      return FutureResponse.fail(handleDioError(e));
    } catch (e) {
      return FutureResponse.fail(UNEXPECTED_ERROR);
    }
  }
}
