import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/path_map/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Блока построения пути на карте, позволяет строить маршрут между местоположением
/// пользователя и местом, куда ему нужно придти.
class PathMapBloc extends Bloc<PathMapBlocEvent, PathMapBlocState> {
  static const defaultPathType = PathType.Walk;
  final MapRepository mapRepository;
  final LatLng destPoint;
  final Geolocator geolocator;

  PathMapBloc(
    this.mapRepository,
    this.destPoint,
    this.geolocator,
  ) : super(PathMapBlocMapState(type: defaultPathType));

  PathType type = defaultPathType;
  GoogleMapController controller;
  FutureResponse<LatLng> userPosition;
  FutureResponse<MapRoute> route;

  @override
  Stream<PathMapBlocState> mapEventToState(PathMapBlocEvent event) async* {
    if (event is PathMapBlocInitEvent) {
      controller = event.controller;
      try {
        var position = await geolocator.getCurrentPosition();
        userPosition = FutureResponse.success(
            LatLng(position.latitude, position.longitude));
      } catch (_) {
        userPosition = FutureResponse.fail(LOCATION_ACCESS_DENIED);
      }

      await calculatePath();

      yield PathMapBlocMapState(
        controller: controller,
        userPosition: userPosition,
        route: route,
        type: type,
      );
    }

    if (event is PathMapBlocChangeType) {
      type = event.type;
      await calculatePath();

      yield PathMapBlocMapState(
        controller: controller,
        userPosition: userPosition,
        route: route,
        type: type,
      );
    }
  }

  Future<void> calculatePath() async {
    if (userPosition.hasData) {
      route = await mapRepository.calculatePathBetweenPoints(
          userPosition.data, destPoint, type);
    }
  }
}
