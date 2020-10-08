import 'package:city_go/data/core/localization_constants.dart';
import 'package:dio/dio.dart';

/// Конвертирует [error] в строковую константу, которая описывает произошедшее
String handleDioError(DioError e) {
  var code = e.response?.statusCode;
  if (code == null) throw UNEXPECTED_ERROR;

  switch (code) {
    default:
      return UNEXPECTED_ERROR;
  }
}

/// Абстрактный http клиент, который должен использоваться в приложении
abstract class HttpClient {
  /// GET запрос.
  /// Параметр [path] должен начинаться со знака /
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  });

  /// POST запрос.
  /// Параметр [path] должен начинаться со знака /
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  });

  /// PUT запрос.
  /// Параметр [path] должен начинаться со знака /
  Future<Response<dynamic>> put(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  });

  /// Возвращает url ссылку для загрузки медиа файла (картинка/аудио) путём
  /// слияния [path] и хоста сервера.
  String getMediaPath(String path);
}

/// Реализация клиента, который вызывает методы [dio] c дополненным путём сервера
class HttpClientImpl extends HttpClient {
  static const kServerUrl = 'http://45.90.35.170';
  final Dio dio;

  HttpClientImpl(this.dio);

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    onReceiveProgress,
  }) {
    return dio.get(
      kServerUrl + path,
      options: options,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    onSendProgress,
    onReceiveProgress,
  }) {
    return dio.post(
      kServerUrl + path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response> put(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    onSendProgress,
    onReceiveProgress,
  }) {
    return dio.put(
      kServerUrl + path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  String getMediaPath(String path) => '$kServerUrl/$path';
}
