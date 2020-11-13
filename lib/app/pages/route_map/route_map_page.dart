import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/route_map/bloc/bloc.dart';
import 'package:city_go/constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/domain/entities/map/map_route.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Страница для построения маршрута route.
/// Также у пользователя есть возможность смотреть своё местоположение на карте
class RouteMapPage extends StatefulWidget {
  final r.Route route;

  RouteMapPage({
    Key key,
    @required this.route,
  })  : assert(route != null),
        super(key: key);

  @override
  _RouteMapPageState createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  static const minZoom = 12.0;

  // ignore: close_sinks
  RouteMapBloc bloc;
  LatLng userPosition;

  /// Флаг, обозначающий, что нужно переключиться на позицию пользователя.
  /// Активируется, когда пользователь нажимает специальную кнопку
  bool needShowPosition = false;

  bool needShowRoute = true;

  bool isRoutePathShowed = false;

  Set<Marker> markers = {};

  Map<PolylineId, Polyline> polylines;

  @override
  void initState() {
    bloc = sl<RouteMapBloc>(param1: widget.route);
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
      key: Key('RoutePageScaffold'),
      body: StreamBuilder<RouteMapBlocState>(
        key: Key('RoutePageStreamBuilder'),
        initialData: bloc.state,
        stream: bloc,
        builder: (_, snap) {
          var state = snap.data as RouteMapBlocMapState;

          if (markers.isEmpty &&
              widget.route.routePlaces.isNotEmpty &&
              bloc.pointIcon != null)
            initPlaceMarkers(widget.route.routePlaces);

          if (state.route?.hasData == true) initPolylines(state.route.data);

          if (state.route?.hasData == true &&
              state.controller != null &&
              needShowRoute) {
            needShowRoute = false;
            var data = state.route.data;
            changeCameraPositionAfterWayFound(state.controller,
                data.coordinates.first, data.coordinates.last);
          }

          if (state.userPosition?.hasData == true && needShowPosition) {
            needShowPosition = false;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => state.controller
                  ?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: state.userPosition.data, zoom: 15),
              )),
            );
          }

          if (state.userPosition?.hasError == true && bloc.showError) {
            bloc.showError = false;
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                CityToast.showToast(context, state.userPosition.errorCode));
          }
          if (state.route?.hasError == true && bloc.showError) {
            bloc.showError = false;
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => CityToast.showToast(context, state.route.errorCode));
          }

          return Stack(
            children: [
              GoogleMap(
                key: Key('RoutePageGoogleMap'),
                onMapCreated: (c) => bloc.add(RouteMapBlocInitEvent(c)),
                markers: markers != null ? Set<Marker>.from(markers) : null,
                polylines: polylines != null
                    ? Set<Polyline>.from(polylines.values)
                    : null,
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
                          bloc.add(RouteMapBlocFindLocation());
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
              Positioned(
                left: 15,
                bottom: 55,
                child: AdaptiveButton.orangeLight(
                  icon: Icons.map,
                  onTap: () {
                    bloc.add(RouteMapBlocUpdatePath());
                    setState(() => needShowRoute = true);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
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
      var id = PolylineId('route_path_points');
      markers.addAll([
        Marker(
          markerId: MarkerId('start_point'),
          infoWindow: InfoWindow(title: 'Start'),
          position: LatLng(
            data.coordinates.first.latitude,
            data.coordinates.first.longitude,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
        Marker(
          markerId: MarkerId('end_point'),
          infoWindow: InfoWindow(title: 'End'),
          position: LatLng(
            data.coordinates.last.latitude,
            data.coordinates.last.longitude,
          ),
          icon: null,
        )
      ]);
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

  void initPlaceMarkers(List<FullVisitPlace> routePlaces) {
    for (var place in routePlaces) {
      if (place.latLng == null) continue;
      markers.add(Marker(
        markerId: MarkerId('Place: ${place.id}'),
        infoWindow: InfoWindow(title: place.name),
        onTap: () => print('TapPoint'),
        position: place.latLng.toGoogle(),
        icon: bloc.pointIcon,
      ));
    }
  }
}
