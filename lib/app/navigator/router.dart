import 'package:city_go/app/pages/intro_page/intro_page.dart';
import 'package:city_go/app/pages/main_page/main_page.dart';
import 'package:city_go/app/pages/path_map/path_map_page.dart';
import 'package:city_go/app/pages/profile_auth/profile_auth_page.dart';
import 'package:city_go/app/pages/route_list/route_list_page.dart';
import 'package:city_go/app/pages/route_map/route_map_page.dart';
import 'package:city_go/app/pages/route_single/route_single_page.dart';
import 'package:city_go/app/pages/simple_map/simple_map_page.dart';
import 'package:city_go/app/pages/visit_place_list/visit_list_page.dart';
import 'package:city_go/app/pages/visit_place_single/visit_single_page.dart';
import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Константы для страниц, здесь должны быть перечислены все страницы без исключений
const ROOT = '/';
const INTRO_ANIMATION = '/intro';
const PATH_MAP_PAGE = '/path_map';
const ROUTE_MAP_PAGE = '/route_map';
const PROFILE = '/profile';
const VISIT_LIST = '/visit_list';
const ROUTE_LIST = '/route_list';
const ROUTE_SINGLE = '/route_single';
const VISIT_SINGLE = '/visit_single';
const SIMPLE_MAP = '/map';

/// Роуты, в которые не нужно передавать данные, они основаны на DI
final routes = <String, WidgetBuilder>{
  INTRO_ANIMATION: (_) => IntroPage(),
  ROOT: (_) => MainPage(),
  PROFILE: (_) => ProfileAuthPage(bloc: sl()),
  ROUTE_LIST: (_) => RouteListPage(bloc: sl()),
  SIMPLE_MAP: (_) => SimpleMapPage(bloc: sl()),
};

/// Роуты, в которые необходимо передавать данные.
/// Каждый MaterialPageRoute должен содержать параметр [settings], определяющий
/// его назначение.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case PATH_MAP_PAGE:
      final dest = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => PathMapPage(dest: dest as LatLng),
        settings: settings,
      );
    case ROUTE_MAP_PAGE:
      final route = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => RouteMapPage(route: route as r.Route),
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
    case ROUTE_SINGLE:
      final route = settings.arguments as dynamic;
      return MaterialPageRoute(
        builder: (_) => RouteSinglePage(
          clipped: route,
          bloc: sl.call<RouteSingleBloc>(param1: route.id),
          client: sl(),
        ),
      );
    case VISIT_SINGLE:
      final place = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => VisitSinglePage(
          bloc: sl.call<VisitSingleBloc>(param1: (place as dynamic).id),
          place: place,
          client: sl(),
        ),
      );
    default:
      throw Exception("Route with name ${settings.name} doesn't exists");
  }
}
