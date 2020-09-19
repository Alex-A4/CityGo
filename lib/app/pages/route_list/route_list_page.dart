import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/widgets/route_list/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Страница со списком пеших маршрутов
class RouteListPage extends StatelessWidget {
  final RouteListBloc bloc;

  RouteListPage({Key key, @required this.bloc})
      : assert(bloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CityAppBar(title: Text(context.localization(PATHS_WORD))),
      body: Center(
        child: Text(context.localization(PATHS_WORD)),
      ),
    );
  }
}
