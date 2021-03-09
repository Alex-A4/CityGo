import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/path_map/bloc/bloc.dart';
import 'package:city_go/constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Страница для построения маршрута между положением пользователя и
/// некоторым местом с координатами [dest]
class PathMapPage extends StatefulWidget {
  final LatLng dest;

  PathMapPage({
    Key? key,
    required this.dest,
  }) : super(key: key);

  @override
  _PathMapPageState createState() => _PathMapPageState();
}

class _PathMapPageState extends State<PathMapPage> {
  static const minZoom = 12.0;

  // ignore: close_sinks
  late PathMapBloc bloc;
  LatLng? userPosition;

  /// Флаг, обозначающий, что нужно переключиться на позицию пользователя.
  /// Активируется, когда пользователь нажимает специальную кнопку
  bool needShowPosition = false;

  Set<Marker>? markers;

  Map<PolylineId, Polyline>? polylines;

  @override
  void initState() {
    bloc = sl<PathMapBloc>(param1: widget.dest);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height - kToolbarHeight;

    return Scaffold(
      key: Key('PathPageScaffold'),
      body: StreamBuilder<PathMapBlocState>(
        key: Key('PathPageStreamBuilder'),
        initialData: bloc.state,
        stream: bloc,
        builder: (_, snap) {
          var state = snap.data as PathMapBlocMapState;

          if (state.controller != null)
            initMarkers(state.userPosition?.data, state.controller!);

          if (state.route?.hasData == true) initPolylines(state.route!.data!);

          if (state.userPosition?.hasData == true && needShowPosition) {
            needShowPosition = false;
            WidgetsBinding.instance!.addPostFrameCallback(
              (_) => state.controller
                  ?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: state.userPosition!.data!, zoom: 15),
              )),
            );
          }

          if (state.userPosition?.hasError == true) {
            WidgetsBinding.instance!.addPostFrameCallback((_) =>
                CityToast.showToast(context, state.userPosition!.errorCode!));
          }
          if (state.route?.hasError == true) {
            WidgetsBinding.instance!.addPostFrameCallback(
                (_) => CityToast.showToast(context, state.route!.errorCode!));
          }

          return Stack(
            children: [
              GoogleMap(
                key: Key('PathPageGoogleMap'),
                onMapCreated: (c) => bloc.add(PathMapBlocInitEvent(c)),
                markers: markers != null
                    ? Set<Marker>.from(markers!)
                    : Set<Marker>(),
                polylines: polylines != null
                    ? Set<Polyline>.from(polylines!.values)
                    : Set<Polyline>(),
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                minMaxZoomPreference: MinMaxZoomPreference(minZoom, null),
                initialCameraPosition: kYaroslavlPos,
                cameraTargetBounds: kYaroslavlBounds,
                onTap: (lng) {
                  print(lng);
                },
                compassEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                indoorViewEnabled: true,
                buildingsEnabled: true,
              ),
              Positioned(
                left: 15,
                top: MediaQuery.of(context).padding.top + 15,
                child: AdaptiveButton.orangeLight(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                right: 10,
                top: size * 0.4,
                child: AdaptiveButton.orangeLight(
                  icon: Icons.add,
                  onTap: () =>
                      state.controller?.animateCamera(CameraUpdate.zoomIn()),
                ),
              ),
              Positioned(
                right: 10,
                top: size * 0.5,
                child: AdaptiveButton.orangeLight(
                  icon: Icons.remove,
                  onTap: () async {
                    var level =
                        await state.controller?.getZoomLevel() ?? minZoom;
                    if (level > minZoom)
                      state.controller?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ),
              Positioned(
                right: 15,
                bottom: 55,
                child: !state.isLocationSearching
                    ? AdaptiveButton.orangeLight(
                        icon: Icons.my_location,
                        onTap: () {
                          needShowPosition = true;
                          bloc.add(PathMapBlocFindLocation());
                        },
                      )
                    : AdaptiveButton.widget(
                        widget: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(orangeColor),
                        ),
                        onTap: null,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Инициализация маркеров с точкой назначения и от позиции пользователя
  void initMarkers(LatLng? userPosition, GoogleMapController controller) {
    if ((markers == null || markers?.length == 1) && userPosition != null) {
      markers = {};

      Marker startMarker = Marker(
        markerId: MarkerId('$userPosition'),
        position: LatLng(
          userPosition.latitude,
          userPosition.longitude,
        ),
        infoWindow: InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId('${widget.dest}'),
        position: LatLng(
          widget.dest.latitude,
          widget.dest.longitude,
        ),
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      markers!.add(startMarker);
      markers!.add(destinationMarker);

      changeCameraPositionAfterWayFound(controller, userPosition, widget.dest);
    } else if (markers == null) {
      markers = {};

      Marker destinationMarker = Marker(
        markerId: MarkerId('${widget.dest}'),
        position: LatLng(
          widget.dest.latitude,
          widget.dest.longitude,
        ),
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      markers!.add(destinationMarker);
      changeCameraPositionToDestination(controller);
    }
  }

  /// Позиционирование камеры на точку назначения, если остальные элементы не
  /// удалось инициализировать
  void changeCameraPositionToDestination(GoogleMapController controller) {
    controller.animateCamera(CameraUpdate.newLatLng(widget.dest));
  }

  /// Перемещение камеры так, чтобы входила позиция пользователя и точка назначения
  void changeCameraPositionAfterWayFound(
      GoogleMapController controller, LatLng start, LatLng dest) {
    // Define two position variables
    LatLng _northeastCoordinates;
    LatLng _southwestCoordinates;

    // Calculating to check that
    // southwest coordinate <= northeast coordinate
    if (start.latitude <= dest.latitude) {
      _southwestCoordinates = start;
      _northeastCoordinates = dest;
    } else {
      _southwestCoordinates = dest;
      _northeastCoordinates = start;
    }

    // Accommodate the two locations within the
    // camera view of the map
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            _northeastCoordinates.latitude,
            _northeastCoordinates.longitude,
          ),
          southwest: LatLng(
            _southwestCoordinates.latitude,
            _southwestCoordinates.longitude,
          ),
        ),
        100.0, // padding
      ),
    );
  }

  /// Инициализация маршрута
  void initPolylines(MapRoute data) {
    if (polylines == null) {
      var id = PolylineId('path_to_point');
      polylines = {
        id: Polyline(
          polylineId: id,
          points: data.coordinates,
          width: 3,
          color: Colors.blue,
        ),
      };
    }
  }
}
