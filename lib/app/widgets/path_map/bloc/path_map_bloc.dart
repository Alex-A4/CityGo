import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/path_map/bloc/bloc.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/repositories/map/map_repository.dart';
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
  ) : super(PathMapBlocState(type: defaultPathType));

  PathType type = defaultPathType;
  GoogleMapController? controller;
  FutureResponse<LatLng>? userPosition;
  FutureResponse<MapRoute>? route;

  bool isLocationSearching = false;

  @override
  Stream<PathMapBlocState> mapEventToState(PathMapBlocEvent event) async* {
    if (event is PathMapBlocInitEvent) {
      controller = event.controller;
      yield* defaultAlg;
    }

    if (event is PathMapBlocChangeType) {
      type = event.type;
      await calculatePath();

      yield pathState;
    }

    if (event is PathMapBlocFindLocation) {
      yield* defaultAlg;
    }
  }

  /// Стандартный алгоритм, который включает в себя поиск позиции пользователя,
  /// а затем построение маршрута.
  Stream<PathMapBlocState> get defaultAlg async* {
    yield turnOnFinding;
    await findUserLocation();
    yield turnOffFinding;
    await calculatePath();

    yield pathState;
  }

  PathMapBlocState get turnOnFinding {
    isLocationSearching = true;
    return pathState;
  }

  PathMapBlocState get turnOffFinding {
    isLocationSearching = false;
    return pathState;
  }

  PathMapBlocState get pathState => PathMapBlocState(
        controller: controller,
        userPosition: userPosition,
        route: route,
        type: type,
        isLocationSearching: isLocationSearching,
      );

  Future<void> calculatePath() async {
    if (userPosition?.hasData == true) {
      route = await mapRepository.calculatePathBetweenPoints(
          userPosition!.data!, destPoint, type);
    }
  }

  Future<void> findUserLocation() async {
    try {
      userPosition = FutureResponse.success(await geolocator.getPosition());
    } catch (e) {
      userPosition = FutureResponse.fail(e.toString());
    }
  }
}
