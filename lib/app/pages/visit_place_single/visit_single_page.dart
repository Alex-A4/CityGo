import 'package:city_go/app/general_widgets/description_widget.dart';
import 'package:city_go/app/general_widgets/info_app_bar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/styles/styles.dart';
import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_single/ui/single_visit_content.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Экран для отображения информации о конкретном месте.
class VisitSinglePage extends StatefulWidget {
  final ClippedVisitPlace place;
  final HttpClient client;

  VisitSinglePage({
    Key key = const Key('VisitSinglePage'),
    required this.place,
    required this.client,
  }) : super(key: key);

  @override
  _VisitSinglePageState createState() => _VisitSinglePageState();
}

class _VisitSinglePageState extends State<VisitSinglePage> {
  late VisitSingleBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = sl.call<VisitSingleBloc>(param1: widget.place.id);
    bloc.add(VisitSingleBlocLoadEvent());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VisitSingleBloc, VisitSingleBlocState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is VisitSingleBlocDataState && state.errorCode != null) {
            WidgetsBinding.instance!.addPostFrameCallback(
              (_) => CityToast.showToast(context, state.errorCode!),
            );
          }
        },
        builder: (_, state) {
          FullVisitPlace? place;

          if (state is VisitSingleBlocDataState) {
            place = state.place;
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
                  image: widget.place.logo == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(
                            widget.client.getMediaPath(widget.place.logo!),
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
                          InfoAppBar(title: widget.place.name),
                          Divider(color: orangeColor, height: 1, thickness: 1),
                          if (place == null) loadingIndicator,
                          if (place != null)
                            Expanded(
                              child: SingleVisitContent(
                                place: place,
                                bottomSize: height * 0.1,
                                client: widget.client,
                                placeRepository: bloc.repository,
                              ),
                            ),
                        ],
                      ),
                      if (place != null)
                        DescriptionWidget(
                          description: place.description,
                          images: place.imageSrc,
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
