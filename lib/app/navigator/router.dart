import 'package:city_go/app/pages/main_page/main_page.dart';
import 'package:city_go/app/pages/path_map/path_map_page.dart';
import 'package:city_go/app/pages/profile_auth/profile_auth_page.dart';
import 'package:city_go/app/pages/route_list/route_list_page.dart';
import 'package:city_go/app/pages/route_map/route_map_page.dart';
import 'package:city_go/app/pages/visit_place_list/visit_list_page.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:flutter/material.dart';

/// Константы для страниц, здесь должны быть перечислены все страницы без исключений
const ROOT = '/';
const PATH_MAP_PAGE = '/path_map';
const ROUTE_MAP_PAGE = '/route_map';
const PROFILE = '/profile';
const VISIT_LIST = '/visit_list';
const ROUTE_LIST = '/route_list';

/// Роуты, в которые не нужно передавать данные, они основаны на DI
final routes = <String, WidgetBuilder>{
  ROOT: (_) => MainPage(),
  PROFILE: (_) => ProfileAuthPage(bloc: sl()),
  ROUTE_LIST: (_) => RouteListPage(bloc: sl()),
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
    case VISIT_LIST:
      final map = settings.arguments as Map;
      return MaterialPageRoute(
        builder: (_) => VisitListPage(
          titleCode: map['title'],
          bloc: sl.call(param1: map['type']),
        ),
        settings: settings,
      );
    default:
      throw Exception("Route with name ${settings.name} doesn't exists");
  }
}
