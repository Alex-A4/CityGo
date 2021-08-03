import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/pages/profile_auth/auth_page.dart';
import 'package:city_go/app/pages/profile_auth/settings_page.dart';
import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Страница профиля, где пользователь может регистрироваться/авторизовываться
/// или же посмотреть настройки.
/// Если пользователь не авторизован, то будет показано соответствующее окно,
/// иначе настройки.
class ProfileAuthPage extends StatefulWidget {
  ProfileAuthPage({Key? key}) : super(key: key);

  @override
  _ProfileAuthPageState createState() => _ProfileAuthPageState();
}

class _ProfileAuthPageState extends State<ProfileAuthPage> {
  final ProfileBloc bloc = sl();

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is ProfileNeedAuthState) {
          if (state.errorCode != null) {
            WidgetsBinding.instance!.addPostFrameCallback(
              (_) => CityToast.showToast(context, state.errorCode!),
            );
          }
        }

        if (state is ProfileNeedLoginState) {
          if (state.errorCode != null) {
            WidgetsBinding.instance!.addPostFrameCallback(
              (_) => CityToast.showToast(context, state.errorCode!),
            );
          }
        }
      },
      builder: (_, state) {
        if (state is ProfileAuthenticatedState) {
          return SettingsPage(bloc: bloc, profile: state.profile);
        }
        if (state is ProfileNeedAuthState) {
          return AuthPage(bloc: bloc, isAuth: true);
        }
        if (state is ProfileNeedLoginState) {
          return AuthPage(bloc: bloc, isAuth: false);
        }

        return Container();
      },
    );
  }
}
