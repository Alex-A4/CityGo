import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/route_map/bloc/bloc.dart';
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

  RouteMapBloc(this.route, this.mapRepository) : super(RouteMapBlocMapState());

  GoogleMapController controller;
  FutureResponse<MapRoute> mapRoute;

  @override
  Stream<RouteMapBlocState> mapEventToState(RouteMapBlocEvent event) async* {
    if (event is RouteMapBlocInitEvent) {
      controller = event.controller;
      await calculatePath();

      yield RouteMapBlocMapState(
        controller: controller,
        route: mapRoute,
      );
    }
  }

  Future<void> calculatePath() async {
    mapRoute = await mapRepository.calculatePathForRoute(route);
  }
}
