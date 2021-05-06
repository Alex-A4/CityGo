import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/visit_place_list/bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_list/ui/filter_widget.dart';
import 'package:city_go/app/widgets/visit_place_list/ui/visit_item.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Экран, отображающий список мест, который пользователь может посетить.
/// Тип места должен быть заложен в [bloc].
/// [titleCode] используется для заголовка, чтобы не определять его по типу.
class VisitListPage extends StatefulWidget {
  final String titleCode;
  final VisitListBloc bloc;

  VisitListPage({
    Key? key,
    required this.titleCode,
    required this.bloc,
  }) : super(key: key) {
    bloc.add(VisitListBlocLoadPlacesEvent());
  }

  @override
  _VisitListPageState createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  final ScrollController controller = ScrollController();
  bool isLoading = true;
  bool isEndOfList = false;

  bool displayFilter = false;

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
    final height = (mq.size.height - mq.padding.top - kToolbarHeight) / 3;

    return StreamBuilder<VisitListBlocState>(
      key: Key('VisitListStreamBuilder'),
      stream: widget.bloc.stream,
      initialData: widget.bloc.state,
      builder: (c, snap) {
        final state = snap.data;
        PlaceSortType sortType = PlaceSortType.Rating;
        List<ClippedVisitPlace> places = [];

        if (state is VisitListBlocPlaceLoadingState) {
          isLoading = true;
          sortType = state.sortType;
          places = state.places;
        } else if (state is VisitListBlocPlaceState) {
          isLoading = false;
          sortType = state.sortType;
          places = state.places;
          if (state.errorCode != null) {
            isEndOfList = true;
            WidgetsBinding.instance!.addPostFrameCallback(
                (_) => CityToast.showToast(c, state.errorCode!));
          }
          isEndOfList = state.isEndOfList;
        }

        PreferredSizeWidget appBar;
        if (displayFilter)
          appBar = FilterWidget(
            activeType: sortType,
            onTap: (type) {
              widget.bloc.add(VisitListBlocChangeSortType(type));
              setState(() => displayFilter = !displayFilter);
            },
          );
        else
          appBar = CityAppBar(
            title: AutoSizeText(context.localization(widget.titleCode)),
            actions: [
              IconButton(
                onPressed: () => setState(() => displayFilter = !displayFilter),
                icon: Icon(Icons.filter_list_alt),
              ),
            ],
          );

        return Scaffold(
          key: Key('VisitListScaffold'),
          backgroundColor: Colors.grey[800],
          appBar: appBar,
          body: ListView.builder(
            key: Key('VisitListListView'),
            controller: controller,
            itemCount: places.length + (isLoading ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == places.length) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(orangeColor)),
                );
              }

              return VisitItem(
                key: Key('VisitItem$index'),
                place: places[index],
                height: height,
                client: sl(),
                placeRepository: widget.bloc.repository,
              );
            },
          ),
        );
      },
    );
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 200 && !isLoading && !isEndOfList) {
      isLoading = true;
      widget.bloc.add(VisitListBlocLoadPlacesEvent());
    }
  }
}
