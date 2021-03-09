import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';

/// Блок для загрузки и взаимодействия с конкретным местом, который загружается
/// с полной информацией.
class VisitSingleBloc extends Bloc<VisitSingleBlocEvent, VisitSingleBlocState> {
  final ProfileStorage storage;
  final PlaceRepository repository;
  final int id;

  VisitSingleBloc({
    required this.storage,
    required this.id,
    required this.repository,
  }) : super(VisitSingleBlocEmptyState());

  FullVisitPlace? place;

  @override
  Stream<VisitSingleBlocState> mapEventToState(
      VisitSingleBlocEvent event) async* {
    if (event is VisitSingleBlocLoadEvent) {
      var user = storage.profile.user;
      if (user == null)
        yield VisitSingleBlocDataState(null, USER_NOT_AUTH);
      else {
        var response =
            await repository.getConcretePlace(id: id, token: user.accessToken!);
        if (response.hasError)
          yield VisitSingleBlocDataState(null, response.errorCode);
        else {
          place = response.data;
          yield VisitSingleBlocDataState(place);
        }
      }
    }
  }
}
