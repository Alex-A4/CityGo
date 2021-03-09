import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/route_map/bloc/bloc.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/storages/map_icons_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Блока построения пути на карте, позволяет строить маршрут для пути, который
/// просматривается. Также позволяет отслеживать местоположение пользователя.
class RouteMapBloc extends Bloc<RouteMapBlocEvent, RouteMapBlocState> {
  final Route route;
  final MapRepository mapRepository;
  final Geolocator geolocator;
  final MapIconsStorage iconsStorage;

  RouteMapBloc(
      this.route, this.mapRepository, this.geolocator, this.iconsStorage)
      : super(RouteMapBlocMapState());

  GoogleMapController? controller;
  FutureResponse<MapRoute>? mapRoute;

  FutureResponse<LatLng>? userPosition;
  bool isLocationSearching = false;
  bool showError = false;

  List<BitmapDescriptor>? pointIcons;

  @override
  Stream<RouteMapBlocState> mapEventToState(RouteMapBlocEvent event) async* {
    if (event is RouteMapBlocInitEvent) {
      controller = event.controller;

      pointIcons = await iconsStorage.future;

      yield turnOnFinding;
      await findUserLocation();
      yield turnOffFinding;
      await calculatePath();

      yield routeState;
    }

    if (event is RouteMapBlocUpdatePath) {
      if (!mapRoute!.hasData) {
        await calculatePath();
      }
      yield routeState;
    }

    if (event is RouteMapBlocFindLocation) {
      yield turnOnFinding;
      await findUserLocation();
      yield turnOffFinding;
    }
  }

  /// Включаем поиск местоположения
  RouteMapBlocMapState get turnOnFinding {
    isLocationSearching = true;
    return routeState;
  }

  /// Выключаем поиск местоположения
  RouteMapBlocMapState get turnOffFinding {
    isLocationSearching = false;
    return routeState;
  }

  RouteMapBlocMapState get routeState => RouteMapBlocMapState(
        controller: controller,
        route: mapRoute,
        isLocationSearching: isLocationSearching,
        userPosition: userPosition,
      );

  Future<void> calculatePath() async {
    mapRoute = await mapRepository.calculatePathForRoute(route);
    if (mapRoute?.hasError == true) showError = true;
  }

  Future<void> findUserLocation() async {
    try {
      userPosition = FutureResponse.success(await geolocator.getPosition());
    } catch (e) {
      userPosition = FutureResponse.fail(e.toString());
      showError = true;
    }
  }
}
