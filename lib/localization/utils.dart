import 'package:flutter/widgets.dart';

import 'localization.dart';

/// Расширение билд контекста.
extension LocalizationExtension on BuildContext {
  /// Метод для получения локализации у данного контекста по коду
  String localization(String code) {
    return CityGoLocalization.of(this).get(code);
  }

  /// Получение текущей локализации приложения
  String get locale {
    return CityGoLocalization.of(this).locale;
  }
}
