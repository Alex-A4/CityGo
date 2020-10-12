import 'package:bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/geolocator.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bloc.dart';
import 'package:meta/meta.dart';

/// Блок списка мест, которые можно посетить.
/// Блок содержит информацию о выбранном типе мест (кафе/парки) и загружает
/// эту информацию с сервера.
class VisitListBloc extends Bloc<VisitListBlocEvent, VisitListBlocState> {
  final PlaceRepository repository;
  final PlaceType type;
  final ProfileStorage storage;
  final Geolocator geolocator;

  VisitListBloc({
    @required this.type,
    @required this.repository,
    @required this.storage,
    @required this.geolocator,
    this.sortType = PlaceSortType.Rating,
  }) : super(VisitListBlocPlaceState(type, [], sortType, false));

  PlaceSortType sortType;
  List<ClippedVisitPlace> places = [];

  @override
  Stream<VisitListBlocState> mapEventToState(VisitListBlocEvent event) async* {
    if (event is VisitListBlocLoadPlacesEvent) {
      yield* loadPlaces();
    }

    if (event is VisitListBlocChangeSortType) {
      if (event.type != sortType) {
        sortType = event.type;
        yield* loadPlaces();
      }
    }
  }

  /// Функция по загрузке мест
  Stream<VisitListBlocState> loadPlaces() async* {
    yield VisitListBlocPlaceLoadingState(type, places, sortType);

    var user = storage.profile.user;
    if (user == null)
      yield VisitListBlocPlaceState(
          type, places, sortType, true, USER_NOT_AUTH);
    else {
      LatLng latLng;
      if (sortType == PlaceSortType.Distance) {
        try {
          latLng = await geolocator.getPosition();
        } catch (e) {
          yield VisitListBlocPlaceState(type, places, sortType, true, e);
          return;
        }
      }

      var response = await repository.getPlaces(
        placeType: type,
        token: user.accessToken,
        offset: places.length,
        sortType: sortType,
        latLng: latLng,
      );
      if (response.hasError)
        yield VisitListBlocPlaceState(
            type, places, sortType, true, response.errorCode);
      else {
        if (response.data.isEmpty)
          yield VisitListBlocPlaceState(type, places, sortType, true);
        else {
          places.addAll(response.data);
          yield VisitListBlocPlaceState(type, places, sortType, false);
        }
      }
    }
  }
}
