import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Класс, описывающий настройки приложения, которые могут изменяться.
///
/// Объекты настроек можно сравнивать с использованием оператора ==.
/// При сравнении используются данные из [props].
@immutable
class Settings extends Equatable {
  /// Флаг, определяющий, нужно ли показывать уведомления
  static const DISPLAY_NOTIFICATION = 'notification';
  final bool displayNotification;

  /// Конструктор настроек.
  /// Если какие-то параметры не указаны, они инициализируются значениями
  /// по-умолчанию.
  const Settings({this.displayNotification = true});

  /// Фабрика по созданию настроек из JSON объекта.
  factory Settings.fromJson(Map<String, dynamic> json) {
    if (json == null) return Settings(); // по-умолчанию

    return Settings(displayNotification: json[DISPLAY_NOTIFICATION]);
  }

  /// Метод для создания нового объекта настроек на основе предыдущего и новых
  /// значений, находящихся в [newData].
  /// Ключами [newData] должны являться константы флагов,
  /// например [DISPLAY_NOTIFICATION].
  Settings copyWith(Map<String, dynamic> newData) {
    return Settings(
      displayNotification:
          newData[DISPLAY_NOTIFICATION] ?? this.displayNotification,
    );
  }

  /// Метод для конвертации настроек в JSON формат
  Map<String, dynamic> toJson() => {
        DISPLAY_NOTIFICATION: displayNotification,
      };

  @override
  List<Object> get props => [displayNotification];
}
