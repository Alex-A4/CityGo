import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/rating_widget.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/repositories/audio_player/audio_player.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Виджет контента, который отображает информацию о маршруте
class SingleRouteContent extends StatelessWidget {
  final r.Route route;
  final double bottomSize;
  final HttpClient client;

  SingleRouteContent({
    Key key,
    @required this.route,
    @required this.bottomSize,
    @required this.client,
  })  : assert(route != null && bottomSize != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.subtitle2;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getIconWithSub(
                      Icons.volume_up,
                      route.audio == null || route.audio.isEmpty
                          ? null
                          : () => sl<CityAudioPlayer>()
                              .startPlayer(client.getMediaPath(route.audio)),
                      context.localization(START_SOUND),
                      style,
                    ),
                    getIconWithSub(
                      Icons.add_road,
                      route.cords.isEmpty
                          ? null
                          : () => Navigator.of(context)
                              .pushNamed(ROUTE_MAP_PAGE, arguments: route),
                      context.localization(CREATE_PATH),
                      style,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              FlatButton(
                onPressed: () {
                  print('ОБЩАЯ ИНФА');
                },
                child: Text(
                  context.localization(GENERAL_INFO),
                  style: style.copyWith(fontSize: 18),
                ),
              ),
              SizedBox(height: 30),
              getInfoRow(
                  LENGTH_WORD,
                  '${route.length} ${context.localization(KM_WORD)}',
                  context,
                  style),
              SizedBox(height: 20),
              getInfoRow(GO_TIME, '${route.goTime}', context, style),
              SizedBox(height: 50),
              RatingWidget(rating: route.rating),
              SizedBox(height: bottomSize + 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInfoRow(
      String titleCode, String text, BuildContext context, TextStyle sub2) {
    final f = sub2.copyWith(
      fontSize: 16,
      decoration: TextDecoration.none,
      fontFamily: 'Jost',
      fontWeight: FontWeight.w400,
    );
    return Row(
      children: [
        Text('${context.localization(titleCode)}:', style: f),
        SizedBox(width: 10),
        Text(text, style: f),
      ],
    );
  }

  Widget getIconWithSub(
      IconData icon, Function onTap, String subtitle, TextStyle sub2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdaptiveButton.orangeTransparent(icon: icon, onTap: onTap),
        SizedBox(height: 10),
        Text(subtitle.toUpperCase(), style: sub2),
      ],
    );
  }
}
