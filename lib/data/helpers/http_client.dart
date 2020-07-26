import 'package:dio/dio.dart';

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
}

/// Реализация клиента, который вызывает методы [dio] c дополненным путём сервера
class HttpClientImpl extends HttpClient {
  static const kServerUrl = 'http://serverUrl.ru';
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
}
