import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:flutter/material.dart';

/// Экран для отображения информации о конкретном месте.
class VisitSinglePage extends StatelessWidget {
  final ClippedVisitPlace place;
  final VisitSingleBloc bloc;

  VisitSinglePage({Key key, @required this.bloc, @required this.place})
      : assert(bloc != null && place != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
