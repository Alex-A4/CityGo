import 'package:bloc/bloc.dart';
import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/repositories/profile/user_remote_repository.dart';
import 'package:meta/meta.dart';

/// Блок профиля, который также отвечает за авторизацию.
/// Если пользователь авторизован, то состояние должно содержать профиль, инчае
/// должно содержать состояние необходимой авторизации.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileStorage storage;
  final UserRemoteRepository repository;

  ProfileBloc({@required this.storage, @required this.repository})
      : super(
          storage.profile.user != null
              ? ProfileAuthenticatedState(storage.profile)
              : ProfileNeedAuthState(),
        );

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    /// Событие авторизации через внешние источники
    if (event is ProfileAuthExternalEvent) {
      var response = await repository.authWithExternalService(event.user);
      if (response.hasData) {
        var profile = await storage.updateProfile(user: response.data);
        yield ProfileAuthenticatedState(profile);
      } else {
        yield ProfileNeedAuthState(errorCode: response.errorCode);
      }
    }

    /// Событие авторизации на сервере
    if (event is ProfileAuthInternalEvent) {
      var response =
          await repository.authNewUser(event.userName, event.password);
      if (response.hasData) {
        var profile = await storage.updateProfile(user: response.data);
        yield ProfileAuthenticatedState(profile);
      } else {
        yield ProfileNeedAuthState(errorCode: response.errorCode);
      }
    }

    if (event is ProfileLogInEvent) {
      var response = await repository.logInUser(event.userName, event.password);
      if (response.hasData) {
        var profile = await storage.updateProfile(user: response.data);
        yield ProfileAuthenticatedState(profile);
      } else {
        yield ProfileNeedLoginState(errorCode: response.errorCode);
      }
    }

    /// Перенаправление со страницы регистрации на страницу авторизации
    if (event is ProfileGoToLoginEvent) {
      yield ProfileNeedLoginState();
    }
    if (event is ProfileLogoutEvent) {
      await storage.clearField(user: true);
      yield ProfileNeedAuthState();
    }
  }
}
