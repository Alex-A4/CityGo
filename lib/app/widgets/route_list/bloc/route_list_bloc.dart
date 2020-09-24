import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/route_list/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:city_go/domain/repositories/routes/route_repository.dart';

import 'package:meta/meta.dart';

/// Блок списка маршрутов, который загружает и хранит их
class RouteListBloc extends Bloc<RouteListBlocEvent, RouteListBlocState> {
  /// Позволяет загружать маршруты
  final RouteRepository repository;
  final ProfileStorage storage;

  RouteListBloc({
    @required this.repository,
    @required this.storage,
  }) : super(RouteListBlocDisplayState([], false));

  List<RouteClipped> routes = [];

  RouteListBlocDisplayState getDataState(bool isEnd, [String error]) {
    return RouteListBlocDisplayState(List.from(routes), isEnd, error);
  }

  @override
  Stream<RouteListBlocState> mapEventToState(RouteListBlocEvent event) async* {
    if (event is RouteListDownloadEvent) {
      yield RouteListBlocLoadingState(routes);

      var user = storage.profile.user;
      if (user == null)
        yield getDataState(true, USER_NOT_AUTH);
      else {
        final response = await repository.getRoutes(
            token: user.accessToken, offset: routes.length);

        if (response.hasError)
          yield getDataState(true, NO_INTERNET);
        else {
          if (response.data.isNotEmpty) {
            routes.addAll(response.data);
            yield getDataState(false);
          } else {
            yield getDataState(true);
          }
        }
      }
    }
  }
}
