import 'package:city_go/app/general_widgets/description_widget.dart';
import 'package:city_go/app/general_widgets/info_app_bar.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/app/widgets/visit_place_single/ui/single_visit_content.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:flutter/material.dart';

/// Экран для отображения информации о конкретном месте.
class VisitSinglePage extends StatefulWidget {
  final ClippedVisitPlace place;
  final VisitSingleBloc bloc;
  final HttpClient client;

  VisitSinglePage({
    Key key = const Key('VisitSinglePage'),
    @required this.bloc,
    @required this.place,
    @required this.client,
  })  : assert(bloc != null && place != null),
        super(key: key) {
    bloc.add(VisitSingleBlocLoadEvent());
  }

  @override
  _VisitSinglePageState createState() => _VisitSinglePageState();
}

class _VisitSinglePageState extends State<VisitSinglePage> {
  VisitSingleBloc get bloc => widget.bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<VisitSingleBlocState>(
        stream: bloc,
        initialData: bloc.state,
        builder: (_, snap) {
          final state = snap.data;
          FullVisitPlace place;

          if (state is VisitSingleBlocDataState) {
            if (state.errorCode != null)
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => CityToast.showToast(context, state.errorCode));
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
                            widget.client.getMediaPath(widget.place.logo),
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
                                  place: place, bottomSize: height * 0.1),
                            ),
                        ],
                      ),
                      if (place != null)
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
                                    description: place.description,
                                    minHeight: height,
                                    images: place.imageSrc,
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
