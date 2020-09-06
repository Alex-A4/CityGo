import 'package:city_go/app/pages/path_map/path_map_page.dart';
import 'package:city_go/app/pages/route_map/route_map_page.dart';
import 'package:flutter/material.dart';

/// Константы для страниц, здесь должны быть перечислены все страницы без исключений
const ROOT = '/';
const PATH_MAP_PAGE = '/path_map';
const ROUTE_MAP_PAGE = '/route_map';

/// Роуты, в которые не нужно передавать данные, они основаны на DI
final routes = <String, WidgetBuilder>{
  ROOT: (_) => null,
};

/// Роуты, в которые необходимо передавать данные.
/// Каждый MaterialPageRoute должен содержать параметр [settings], определяющий
/// его назначение.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case PATH_MAP_PAGE:
      final dest = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => PathMapPage(dest: dest),
        settings: settings,
      );
    case ROUTE_MAP_PAGE:
      final route = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => RouteMapPage(route: route),
        settings: settings,
      );
    default:
      throw Exception("Route with name ${settings.name} doesn't exists");
  }
}
