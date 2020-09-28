import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/widgets/route_list/bloc/bloc.dart';
import 'package:city_go/app/widgets/route_list/ui/route_list_item.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Страница со списком пеших маршрутов
class RouteListPage extends StatefulWidget {
  final RouteListBloc bloc;

  RouteListPage({
    Key key = const Key('RouteListPage'),
    @required this.bloc,
  })  : assert(bloc != null),
        super(key: key) {
    bloc.add(RouteListDownloadEvent());
  }

  @override
  _RouteListPageState createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  final ScrollController controller = ScrollController();
  bool isLoading = true;
  bool isEndOfList = false;

  @override
  void initState() {
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = (mq.size.height - mq.padding.top - kToolbarHeight) / 2;
    final width = mq.size.width / 2;

    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: CityAppBar(title: Text(context.localization(PATHS_WORD))),
      body: StreamBuilder<RouteListBlocState>(
        stream: widget.bloc,
        initialData: widget.bloc.state,
        builder: (c, snap) {
          final state = snap.data;
          List<RouteClipped> routes = [];
          if (state is RouteListBlocDisplayState) {
            isLoading = false;
            routes = state.routes;
            if (state.errorCode != null)
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => CityToast.showToast(c, state.errorCode));
            isEndOfList = state.isEndOfList;
          } else if (state is RouteListBlocLoadingState) {
            routes = state.routes;
            isLoading = true;
          }

          return GridView.builder(
            controller: controller,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: width / height,
            ),
            itemCount: routes.length + (isLoading ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == routes.length) {
                return Center(child: CircularProgressIndicator());
              }

              return RouteItem(
                key: Key('RouteItem$index'),
                route: routes[index],
              );
            },
          );
        },
      ),
    );
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 200 && !isLoading && !isEndOfList) {
      isLoading = true;
      widget.bloc.add(RouteListDownloadEvent());
    }
  }
}

