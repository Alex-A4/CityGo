import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/widgets/visit_place_list/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

class VisitListPage extends StatelessWidget {
  final String titleCode;
  final VisitListBloc bloc;

  VisitListPage({
    Key key,
    @required this.titleCode,
    @required this.bloc,
  })  : assert(titleCode != null && bloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CityAppBar(title: Text(context.localization(titleCode))),
      body: Center(
        child: Text(context.localization(titleCode)),
      ),
    );
  }
}
