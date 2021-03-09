import 'package:equatable/equatable.dart';

/// Ответ с ожиданием, который может закончиться с ошибкой.
/// Используется в ситуациях, когда нужно поймать исключение и вернуть ошибку
/// вместо результата.
class FutureResponse<T> extends Equatable {
  /// Код ошибки из локализации
  final String? errorCode;

  /// Результат, который был получен в процессе выполнения некоторого действия
  final T? data;

  bool get hasError => errorCode != null;

  bool get hasData => data != null;

  FutureResponse(this.errorCode, this.data);

  factory FutureResponse.success(T? data) => FutureResponse(null, data);

  factory FutureResponse.fail(String code) => FutureResponse(code, null);

  @override
  List<Object?> get props => [errorCode, data];
}
