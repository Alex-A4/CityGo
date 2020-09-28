import 'package:city_go/app/general_widgets/info_app_bar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/route_single/bloc/bloc.dart';
import 'package:city_go/app/general_widgets/description_widget.dart';
import 'package:city_go/app/widgets/route_single/ui/single_content.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:flutter/material.dart';

/// Экран отображения информации об одном конкретном маршруте
class RouteSinglePage extends StatefulWidget {
  final RouteClipped clipped;
  final RouteSingleBloc bloc;

  RouteSinglePage({
    Key key = const Key('RouteSinglePage'),
    @required this.clipped,
    @required this.bloc,
  })  : assert(clipped != null && bloc != null),
        super(key: key) {
    bloc.add(RouteSingleBlocLoadEvent());
  }

  @override
  _RouteSinglePageState createState() => _RouteSinglePageState();
}

class _RouteSinglePageState extends State<RouteSinglePage> {
  RouteSingleBloc get bloc => widget.bloc;

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
                                  route: route, bottomSize: height * 0.1),
                            ),
                        ],
                      ),
                      if (route != null)
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            child: DraggableScrollableSheet(
                              minChildSize: 0.1,
                              maxChildSize: heightPercent,
                              initialChildSize: 0.1,
                              builder: (_, c) {
                                return SingleChildScrollView(
                                  child: DescriptionWidget(
                                    description: route.description,
                                    controller: c,
                                    minHeight: height,
                                  ),
                                  controller: c,
                                );
                              },
                            ),
                          ),
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
