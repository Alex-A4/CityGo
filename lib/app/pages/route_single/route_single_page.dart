import 'package:city_go/app/general_widgets/info_app_bar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:flutter/material.dart';

/// Экран отображения информации об одном конкретном маршруте
class RouteSinglePage extends StatefulWidget {
  final RouteClipped clipped;
  final HttpClient client;

  RouteSinglePage({
    Key key = const Key('RouteSinglePage'),
    @required this.clipped,
    this.client,
  })  : assert(clipped != null),
        super(key: key);

  @override
  _RouteSinglePageState createState() => _RouteSinglePageState();
}

class _RouteSinglePageState extends State<RouteSinglePage> {
  // ignore: close_sinks
  RouteSingleBloc bloc;

  @override
  void initState() {
    bloc =
        RouteSingleBloc(storage: sl(), repository: sl(), id: widget.clipped.id);
    bloc.add(RouteSingleBlocLoadEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<RouteSingleBlocState>(
        stream: bloc,
        initialData: bloc.state,
        builder: (_, snap) {
          final state = snap.data;
          r.Route route;
          if (state is RouteSingleBlocDataState) {
            if (state.errorCode != null)
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => CityToast.showToast(context, state.errorCode));
            route = state.route;
          }
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  // widget.client.getMediaPath(widget.clipped.image.path),
                  widget.clipped.image.path,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Color(0xBB000000),
              child: Column(
                children: [
                  InfoAppBar(title: widget.clipped.title),
                  Divider(color: orangeColor, height: 1, thickness: 1),
                  if (route == null) loadingIndicator,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget get loadingIndicator => Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
          ),
        ),
      );
}
