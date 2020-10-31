import 'package:city_go/app/general_widgets/ui_constants.dart';
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
      theme: ThemeData(
        primaryColor: Colors.grey[800],
        accentColor: Colors.grey[800],
        textTheme: TextTheme(
          headline4: TextStyle(
            fontSize: 24,
            fontFamily: 'MontserRat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headline6: TextStyle(
            fontFamily: 'Jost',
            color: lightGrey,
            fontSize: 25,
            letterSpacing: 1.5,
          ),
          subtitle1: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontFamily: 'MontserRat'),
          subtitle2: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'AleGrey',
              decoration: TextDecoration.underline),
          bodyText2: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      initialRoute: ROOT,
      routes: routes,
      onGenerateRoute: generateRoute,
    );
  }
}
