import 'package:city_go/app/widgets/path_map/bloc/bloc.dart';
import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:city_go/app/widgets/route_list/bloc/bloc.dart';
import 'package:city_go/app/widgets/route_map/bloc/bloc.dart';
import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_list/bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/data/repositories/map/distance_calculator.dart';
import 'package:city_go/data/repositories/map/map_repository_impl.dart';
import 'package:city_go/data/repositories/profile/profile_repository_impl.dart';
import 'package:city_go/data/repositories/profile/user_remote_repo_impl.dart';
import 'package:city_go/data/repositories/routes/route_repository_impl.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Сервис локатор приложения, который отвечает за DI всех классов.
/// Для получения класса, необходимо вызвать
/// ```
/// sl<MyClass>();
/// ```
/// указав в качестве MyClass название класса, объект которого необходимо получить
GetIt sl = GetIt.instance;

/// Инициализация локатора всеми зависимости, которые встречаются в приложении
/// Чем ниже находится секция, тем больше зависимостей она использует и наоборот.
Future<void> initServiceLocator() async {
  /// External
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  sl.registerSingleton<HiveInterface>(Hive);
  sl.registerSingleton<Connectivity>(Connectivity());
  sl.registerFactory<Dio>(() => Dio());
  sl.registerSingleton<Geolocator>(GeolocatorImpl());

  sl.registerSingleton<PolylinePoints>(PolylinePoints());
  sl.registerSingleton<NetworkChecker>(NetworkCheckerImpl(sl()));
  sl.registerSingleton<DistanceCalculator>(DistanceCalculatorImpl());
  sl.registerFactory<HttpClient>(() => HttpClientImpl(sl()));

  /// Repositories
  sl.registerFactory<UserRemoteRepository>(
      () => UserRemoteRepositoryImpl(sl(), sl()));
  sl.registerFactory<ProfileRepository>(
      () => ProfileRepositoryImpl(hive: sl()));
  sl.registerFactory<MapRepository>(() => MapRepositoryImpl(sl(), sl(), sl()));
  sl.registerFactory<RouteRepository>(() => RouteRepositoryImpl(sl(), sl()));
  sl.registerFactory<PlaceRepository>(() => PlaceRepositoryImpl(sl(), sl()));

  /// Storage
  sl.registerSingleton<ProfileStorage>(ProfileStorageImpl(repository: sl()));
  await sl<ProfileStorage>().initStorage();

  /// Blocs
  sl.registerFactory<ProfileBloc>(
      () => (ProfileBloc(storage: sl(), repository: sl())));

  sl.registerFactory<RouteListBloc>(
      () => RouteListBloc(storage: sl(), repository: sl()));
  sl.registerFactoryParam<RouteSingleBloc, int, void>(
      (p1, _) => RouteSingleBloc(id: p1, repository: sl(), storage: sl()));

  sl.registerFactoryParam<VisitListBloc, PlaceType, void>(
    (p1, _) => VisitListBloc(
        type: p1, repository: sl(), storage: sl(), geolocator: sl()),
  );
  sl.registerFactoryParam<VisitSingleBloc, int, void>(
      (p1, _) => VisitSingleBloc(id: p1, repository: sl(), storage: sl()));

  sl.registerFactoryParam<PathMapBloc, LatLng, void>(
      (p1, _) => PathMapBloc(sl(), p1, sl()));
  sl.registerFactoryParam<RouteMapBloc, Route, void>(
      (p1, _) => RouteMapBloc(p1, sl(), sl()));
}
