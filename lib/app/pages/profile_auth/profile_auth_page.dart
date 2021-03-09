import 'package:city_go/app/general_widgets/toast_widget.dart';
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

  ProfileAuthPage({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileState>(
      stream: bloc,
      initialData: bloc.state,
      builder: (_, snap) {
        final state = snap.data;
        if (state is ProfileAuthenticatedState) {
          return SettingsPage(bloc: bloc, profile: state.profile);
        }
        if (state is ProfileNeedAuthState) {
          if (state.errorCode != null)
            WidgetsBinding.instance!.addPostFrameCallback(
                (_) => CityToast.showToast(context, state.errorCode!));
          return AuthPage(bloc: bloc, isAuth: true);
        }
        if (state is ProfileNeedLoginState) {
          if (state.errorCode != null)
            WidgetsBinding.instance!.addPostFrameCallback(
                (_) => CityToast.showToast(context, state.errorCode!));
          return AuthPage(bloc: bloc, isAuth: false);
        }

        return Container();
      },
    );
  }
}
