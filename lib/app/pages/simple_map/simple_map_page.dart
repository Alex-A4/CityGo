import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/place_dialog.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/simple_map/bloc/bloc.dart';
import 'package:city_go/constants.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Экран с обычной картой, которую пользователь может посмотреть, чтобы найти
/// себя и ближайшие к нему объекты.
class SimpleMapPage extends StatefulWidget {
  final SimpleMapBloc bloc;

  SimpleMapPage({Key key, @required this.bloc})
      : assert(bloc != null),
        super(key: key);

  @override
  _SimpleMapPageState createState() => _SimpleMapPageState();
}

class _SimpleMapPageState extends State<SimpleMapPage> {
  SimpleMapBloc get bloc => widget.bloc;

  /// Флаг, обозначающий, что нужно переключиться на позицию пользователя.
  /// Активируется, когда пользователь нажимает специальную кнопку
  bool needShowPosition = true;

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height - kToolbarHeight;

    return Scaffold(
      key: Key('RoutePageScaffold'),
      body: StreamBuilder<SimpleMapBlocState>(
        key: Key('RoutePageStreamBuilder'),
        initialData: bloc.state,
        stream: bloc,
        builder: (_, snap) {
          var state = snap.data as SimpleMapBlocMapState;

          if (state.places != null) addPlacesToMarkers(state.places, context);

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
          if (state.errorCode != null /*&& bloc.showError*/) {
            // bloc.showError = false;
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => CityToast.showToast(context, state.errorCode));
          }

          return Stack(
            key: Key('SimpleMapStackKey'),
            children: [
              GoogleMap(
                key: Key('SimpleMapGoogleMapKey'),
                onMapCreated: (c) => bloc.add(SimpleMapBlocInitEvent(c)),
                markers: markers != null ? Set<Marker>.from(markers) : null,
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
                          bloc.add(SimpleMapBlocFindLocation());
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

  void addPlacesToMarkers(List<ClippedVisitPlace> places, BuildContext c) {
    for (final place in places) {
      markers.add(Marker(
        markerId: MarkerId('SimpleMarker-${place.id}'),
        onTap: () => showPlaceDialog(FullVisitPlace.fromClipped(place), c),
        position: place.latLng.toGoogle(),
        flat: true,
        icon: bloc.pointIcons[place.type.iconIndex],
      ));
    }
  }

  void showPlaceDialog(FullVisitPlace place, BuildContext context) {
    showDialog(context: context, builder: (c) => PlaceDialog(place: place));
  }
}
