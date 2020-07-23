import 'package:city_go/data/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/navigator/router.dart';
import 'localization/localization.dart';

/// Входная точка в приложение, просьба не писать здесь много классов
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();

  runApp(LocalizationBuilder((locale) => CityGoApp(locale: locale)));
}

class CityGoApp extends StatelessWidget {
  final Locale locale;

  const CityGoApp({Key key, @required this.locale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// Сперва устанавливается locale, затем получаем фактический язык
      /// приложения на основе языка устройства, поддерживаемых языков и
      /// языка, который был определен приложением (может быть null).
      locale: locale,
      localeResolutionCallback: (deviceLocale, suppLocales) =>
          getAppLocale(deviceLocale, suppLocales, locale),
      // Все языки, поддерживаемые приложением
      supportedLocales:
          supportedLocales.map((langCode) => Locale(langCode)).toList(),
      localizationsDelegates: [
        CityGoLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: ROOT,
      routes: routes,
      onGenerateRoute: generateRoute,
    );
  }
}
