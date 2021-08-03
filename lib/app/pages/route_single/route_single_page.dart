import 'package:city_go/app/general_widgets/info_app_bar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/styles/styles.dart';
import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/app/general_widgets/description_widget.dart';
import 'package:city_go/app/widgets/route_single/ui/single_content.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Экран отображения информации об одном конкретном маршруте
class RouteSinglePage extends StatefulWidget {
  final RouteClipped clipped;
  final HttpClient client;

  RouteSinglePage({
    Key key = const Key('RouteSinglePage'),
    required this.clipped,
    required this.client,
  }) : super(key: key);

  @override
  _RouteSinglePageState createState() => _RouteSinglePageState();
}

class _RouteSinglePageState extends State<RouteSinglePage> {
  late RouteSingleBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = sl.call<RouteSingleBloc>(param1: widget.clipped.id);
    bloc.add(RouteSingleBlocLoadEvent());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RouteSingleBloc, RouteSingleBlocState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is RouteSingleBlocDataState && state.errorCode != null) {
            WidgetsBinding.instance!.addPostFrameCallback(
              (_) => CityToast.showToast(context, state.errorCode!),
            );
          }
        },
        builder: (_, state) {
          r.Route? route;
          if (state is RouteSingleBlocDataState) {
            route = state.route;
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final mq = MediaQuery.of(context);
              final height = constraints.maxHeight -
                  InfoAppBar.size.height -
                  mq.padding.top -
                  15;
              final heightPercent = (height) / constraints.maxHeight;
              return Container(
                decoration: BoxDecoration(
                  image: widget.clipped.logo == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(
                            widget.client.getMediaPath(widget.clipped.logo!),
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
                child: Container(
                  color: Color(0xBB000000),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    fit: StackFit.expand,
                    children: [
                      Column(
                        children: [
                          InfoAppBar(title: widget.clipped.title),
                          Divider(color: orangeColor, height: 1, thickness: 1),
                          if (route == null) loadingIndicator,
                          if (route != null)
                            Expanded(
                              child: SingleRouteContent(
                                route: route,
                                bottomSize: height * 0.1,
                                client: widget.client,
                                routeRepo: bloc.repository,
                              ),
                            ),
                        ],
                      ),
                      if (route != null)
                        DescriptionWidget(
                          description: route.description,
                          minHeight: constraints.maxHeight * 0.1,
                          maxHeight: constraints.maxHeight * heightPercent,
                        ),
                    ],
                  ),
                ),
              );
            },
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
