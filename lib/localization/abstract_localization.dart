import 'package:flutter/material.dart';

import 'localization.dart';

/// Список поддерживаемых локализаций. Содержит список из languageCode
/// На 0 позиции должен находится русский язык (ru), поскольку он выбирается
/// в качестве языка по умолчанию
final supportedLocales = ['ru', 'en'];

/// Хранилище, которое предоставляет набор загруженных строковых констант
abstract class CityGoLocalization {
  factory CityGoLocalization.platform(Locale locale) {
    return CityGoLocalization.mobile(locale);
  }

  factory CityGoLocalization.mobile(Locale locale) => MobileLocalization(locale);

  /// Текущий язык приложения
  Locale _locale;

  String get locale => _locale.languageCode;

  /// Список строковых констант
  late Map<String, dynamic> _sentences;

  // Конструктор
  CityGoLocalization(this._locale);

  /// Статическая функция, которая позволяет получить объект этого класса через
  /// контекст приложения в любом месте
  static CityGoLocalization? of(BuildContext context) =>
      Localizations.of<CityGoLocalization>(context, CityGoLocalization);

  /// Функция по загрузке списка констант из json файла, который располагается
  /// в директории assets/localization и название стостоит из кода языка,
  /// например ru.json
  Future<Map<String, dynamic>> load();

  Future<void> init() async {
    final map = await load();
    setUpSentences(map);
  }

  /// Метод для инициализации строковых констант, используется при тестировании.
  void setUpSentences(Map<String, dynamic> sentences) => _sentences = sentences;

  /// Получения строковой константы из хранилища по указанному ключу
  ///
  /// В случае отсутствия такого ключа, будет выброшено исключение, которое
  /// должно предупредить разработчика об ошибке на этапе отлаживания
  /// и тестирования прогарммы
  String get(String key) {
    if (!_sentences.containsKey(key))
      throw 'The key $key not exist in file for ${_locale.languageCode} locale';

    return _sentences[key];
  }
}

/// Проверка, поддерживается ли действительно язык нашим приложением
bool isReallySupport(Locale locale) {
  return supportedLocales.contains(locale.languageCode);
}

/// Получение фактической локализации приложения.
/// Если прочитанный язык определен, то возвращаем его.
/// Если язык устройства поддерживается, то возвращаем его,
/// иначе язык по умолчанию
Locale getAppLocale(
    Locale? deviceLocale, Iterable<Locale> suppLocales, Locale? readLocale) {
  if (readLocale != null) return readLocale;
  if (deviceLocale != null && isReallySupport(deviceLocale))
    return deviceLocale;
  else
    return suppLocales.first;
}

/// Делегат, который предоставляет инструменты по загрузке собственной локализации
class CityGoLocalizationDelegate extends LocalizationsDelegate<CityGoLocalization> {
  final LocalizationCreator creator;

  CityGoLocalizationDelegate({LocalizationCreator? creator})
      : this.creator = creator ?? kDefaultCreator;

  /// Проверка, поддерживается ли входной язык нашим приложением.
  /// Возвращаем всегда true, чтобы не получать ошибку.
  /// Если язык не будет поддерживаться, он будет установлен на язык по умолчанию.
  @override
  bool isSupported(Locale locale) => true;

  /// Загрузка локализации для языка, определенного [locale].
  /// Если язык не поддерживается нашим приложением, то передаем английский
  /// язык по умолчанию
  @override
  Future<CityGoLocalization> load(Locale locale) async {
    var localization = isReallySupport(locale)
        ? creator(locale)
        : creator(Locale(supportedLocales[0]));
    await localization.init();
    return localization;
  }

  /// Не обновляем локализацию встроенными средствами системы
  @override
  bool shouldReload(_) => false;

  static LocalizationCreator kDefaultCreator =
      (Locale locale) => CityGoLocalization.platform(locale);
}

typedef LocalizationCreator = CityGoLocalization Function(Locale locale);
