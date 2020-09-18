import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:flutter/material.dart';

/// Экран настроек
class SettingsPage extends StatelessWidget {
  final ProfileBloc bloc;

  SettingsPage({Key key, @required this.bloc})
      : assert(bloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Settings')));
  }
}
