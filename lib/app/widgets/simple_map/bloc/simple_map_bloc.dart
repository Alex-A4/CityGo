import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/simple_map/bloc/bloc.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/storages/map_icons_storage.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;

class SimpleMapBloc extends Bloc<SimpleMapBlocEvent, SimpleMapBlocState> {
  final PlaceRepository placeRepository;
  final Geolocator geolocator;
  final ProfileStorage profileStorage;
  final MapIconsStorage iconsStorage;

  SimpleMapBloc(this.geolocator, this.iconsStorage, this.placeRepository,
      this.profileStorage)
      : super(SimpleMapBlocMapState());

  g.GoogleMapController controller;

  FutureResponse<g.LatLng> userPosition;
  bool isLocationSearching = false;
  bool showError = false;

  List<g.BitmapDescriptor> pointIcons;

  /// Подписка на поток загрузки меток на карту
  StreamSubscription subscription;

  SimpleMapBlocMapState dataState({
    String errorCode,
    List<ClippedVisitPlace> places,
  }) {
    return SimpleMapBlocMapState(
      userPosition: userPosition,
      isLocationSearching: isLocationSearching,
      controller: controller,
      errorCode: errorCode,
    );
  }

  @override
  Stream<SimpleMapBlocState> mapEventToState(SimpleMapBlocEvent event) async* {
    if (event is SimpleMapBlocInitEvent) {
      controller = event.controller;

      pointIcons = await iconsStorage.future;

      yield turnOnFinding;
      await findUserLocation();
      yield turnOffFinding;
      subscription = placeRepository
          .getAllPlacesStream(token: profileStorage?.profile?.user?.accessToken)
          .listen((p) => this.add(SimpleMapBlocAddPlaces(p)));

      yield dataState();
    }

    if (event is SimpleMapBlocFindLocation) {
      yield turnOnFinding;
      await findUserLocation();
      yield turnOffFinding;
    }

    if (event is SimpleMapBlocAddPlaces) {
      if (event.places.hasData) {
        yield dataState(places: event.places.data);
      } else {
        subscription.cancel();
        showError = true;
        yield dataState(errorCode: event.places.errorCode);
      }
    }
  }

  /// Включаем поиск местоположения
  SimpleMapBlocMapState get turnOnFinding {
    isLocationSearching = true;
    return dataState();
  }

  /// Выключаем поиск местоположения
  SimpleMapBlocMapState get turnOffFinding {
    isLocationSearching = false;
    return dataState();
  }

  Future<void> findUserLocation() async {
    try {
      userPosition = FutureResponse.success(await geolocator.getPosition());
    } catch (e) {
      userPosition = FutureResponse.fail(e);
      showError = true;
    }
  }

  @override
  Future<Function> close() {
    subscription?.cancel();
    return super.close();
  }
}
