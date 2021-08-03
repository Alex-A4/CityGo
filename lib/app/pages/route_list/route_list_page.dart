import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/styles/styles.dart';
import 'package:city_go/app/widgets/route_list/bloc/bloc.dart';
import 'package:city_go/app/widgets/route_list/ui/route_list_item.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Страница со списком пеших маршрутов
class RouteListPage extends StatefulWidget {
  RouteListPage({
    Key key = const Key('RouteListPage'),
  }) : super(key: key);

  @override
  _RouteListPageState createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  late RouteListBloc bloc;

  final ScrollController controller = ScrollController();
  bool isLoading = true;
  bool isEndOfList = false;

  @override
  void initState() {
    bloc = sl();
    bloc.add(RouteListDownloadEvent());
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = (mq.size.height - mq.padding.top - kToolbarHeight) / 2;
    final width = mq.size.width / 2;

    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: CityAppBar(title: AutoSizeText(context.localization(PATHS_WORD))),
      body: BlocConsumer<RouteListBloc, RouteListBlocState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is RouteListBlocDisplayState && state.errorCode != null) {
            WidgetsBinding.instance!.addPostFrameCallback(
              (_) => CityToast.showToast(context, state.errorCode!),
            );
          }
        },
        builder: (c, state) {
          List<RouteClipped> routes = [];
          if (state is RouteListBlocDisplayState) {
            isLoading = false;
            routes = state.routes;

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
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(orangeColor),
                  ),
                );
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
      bloc.add(RouteListDownloadEvent());
    }
  }
}
