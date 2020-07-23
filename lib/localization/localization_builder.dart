import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Виджет, который хранит локализацию приложения и позволяет обновлять её
class LocalizationBuilder extends StatefulWidget {
  final Function(Locale locale) buildApp;

  LocalizationBuilder(this.buildApp, {Key key}) : super(key: key);

  @override
  _LocalizationBuilderState createState() => _LocalizationBuilderState();

  /// Статический метод для смены локализации приложения
  /// Находит state текущего виджета и обновляет его локализацию
  static void setLocale(BuildContext context, Locale locale) {
    _LocalizationBuilderState state =
        context.findAncestorStateOfType<_LocalizationBuilderState>();
    state.saveAppLocale(locale);
  }
}

/// Получаем локализацию приложения, и устанавливаем [widget.child] в качестве
/// основного виджета для приложения.
class _LocalizationBuilderState extends State<LocalizationBuilder> {
  // Язык, который активирован в приложении
  Locale locale;

  // Флаг, означающий, что приложение запущено первый раз
  bool isLoaded = false;

  /// Если приложение запущено в первый раз и локализация не установлена, то
  /// читаем её из хранилища, иначе сразу обновляем виджет.
  ///
  /// ЕСли не удастся прочитать данные, то локализация будет установлена далее
  /// в зависимости от локализации устройства
  @override
  Widget build(BuildContext context) {
    if (isLoaded)
      return widget.buildApp(locale);
    else {
      getAppLocale();
      return Container();
    }
  }

  /// Читаем languageCode из локального хранилища, если она там есть, то сохраняем.
  /// Затем обновляем состояние, подняв флаг, что данные загружены
  Future<void> getAppLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('locale'))
      this.locale = Locale(prefs.getString('locale'));

    setState(() => isLoaded = true);
  }

  /// Сохраняем languageCode в локальное хранилище
  Future<void> saveAppLocale(Locale locale) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() => this.locale = locale);
  }
}
