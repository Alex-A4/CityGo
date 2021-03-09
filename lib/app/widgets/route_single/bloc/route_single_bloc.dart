import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/repositories/routes/route_repository.dart';

/// Блок для отображения конкретного маршрута и загрузки его данных
class RouteSingleBloc extends Bloc<RouteSingleBlocEvent, RouteSingleBlocState> {
  final RouteRepository repository;
  final ProfileStorage storage;
  final int id;

  RouteSingleBloc({
    required this.id,
    required this.repository,
    required this.storage,
  }) : super(RouteSingleBlocEmptyState());

  Route? route;

  @override
  Stream<RouteSingleBlocState> mapEventToState(
      RouteSingleBlocEvent event) async* {
    if (event is RouteSingleBlocLoadEvent) {
      var user = storage.profile.user;
      if (user == null)
        yield RouteSingleBlocDataState(null, USER_NOT_AUTH);
      else {
        final response =
            await repository.getRoute(id: id, token: user.accessToken!);

        if (response.hasError)
          yield RouteSingleBlocDataState(null, response.errorCode);
        else {
          route = response.data;
          yield RouteSingleBlocDataState(route);
        }
      }
    }
  }
}
