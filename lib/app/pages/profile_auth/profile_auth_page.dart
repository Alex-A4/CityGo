import 'package:city_go/app/pages/profile_auth/auth_page.dart';
import 'package:city_go/app/pages/profile_auth/settings_page.dart';
import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:flutter/material.dart';

/// Страница профиля, где пользователь может регистрироваться/авторизовываться
/// или же посмотреть настройки.
/// Если пользователь не авторизован, то будет показано соответствующее окно,
/// иначе настройки.
class ProfileAuthPage extends StatelessWidget {
  final ProfileBloc bloc;

  ProfileAuthPage({Key key, @required this.bloc})
      : assert(bloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileState>(
      stream: bloc,
      initialData: bloc.state,
      builder: (_, snap) {
        final state = snap.data;
        if (state is ProfileAuthenticatedState) {
          return SettingsPage(bloc: bloc);
        }
        if (state is ProfileNeedAuthState) {
          return AuthPage(bloc: bloc, isAuth: true);
        }
        if (state is ProfileNeedLoginState) {
          return AuthPage(bloc: bloc, isAuth: false);
        }

        return null;
      },
    );
  }
}