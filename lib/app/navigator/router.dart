import 'package:flutter/material.dart';

/// Константы для страниц, здесь должны быть перечислены все страницы без исключений
const ROOT = '/';

/// Роуты, в которые не нужно передавать данные, они основаны на DI
final routes = <String, WidgetBuilder>{
  ROOT: (_) => null,
};

/// Роуты, в которые необходимо передавать данные.
/// Каждый MaterialPageRoute должен содержать параметр [settings], определяющий
/// его назначение.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
//    Пример использования:
//    case SOME_PAGE:
//      final args = settings.arguments as Map;
//      return MaterialPageRoute(
//        builder: (_) => SomePage(
//          data: args['data'],
//        ),
//        settings: settings,
//      );
    default:
      throw Exception('Route with name ${settings.name} doesn\'t exists');
  }
}
