import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/rating_widget.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/repositories/audio_player/audio_player.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Виджет контента для экрана, отображающего место или заведение, куда можно
/// сходить
class SingleVisitContent extends StatelessWidget {
  final FullVisitPlace place;
  final double bottomSize;
  final HttpClient client;

  SingleVisitContent({
    Key key,
    @required this.place,
    @required this.bottomSize,
    @required this.client,
  })  : assert(place != null && bottomSize != null),
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
                    Expanded(
                      child: getIconWithSub(
                        Icons.volume_up,
                        place.audioSrc == null || place.audioSrc.isEmpty
                            ? null
                            : () => sl<CityAudioPlayer>().startPlayer(
                                client.getMediaPath(place.audioSrc)),
                        context.localization(START_SOUND),
                        style,
                      ),
                    ),
                    Expanded(
                      child: getIconWithSub(
                        Icons.add_road,
                        place.latLng == null
                            ? null
                            : () => Navigator.of(context).pushNamed(
                                PATH_MAP_PAGE,
                                arguments: place.latLng.toGoogle()),
                        context.localization(CREATE_PATH),
                        style,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              FlatButton(
                onPressed: () {
                  print('ОБЩАЯ ИНФА');
                },
                child: Text(context.localization(GENERAL_INFO), style: style),
              ),
              SizedBox(height: 30),
              getInfoRow('assets/images/time.png', place.workTime, style),
              SizedBox(height: 5),
              getInfoRow('assets/images/place.png', place.objectAddress, style),
              SizedBox(height: 5),
              getInfoRow(
                  'assets/images/web-site.png', place.objectWebSite, style),
              SizedBox(height: 50),
              RatingWidget(rating: place.rating),
              SizedBox(height: bottomSize + 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInfoRow(String imagePath, String text, TextStyle sub2) {
    final f = sub2.copyWith(
      decoration: TextDecoration.none,
      fontSize: 16,
      fontFamily: 'Jost',
      fontWeight: FontWeight.w400,
    );
    return Row(
      children: [
        Image.asset(imagePath, height: 30, fit: BoxFit.contain),
        SizedBox(width: 10),
        Expanded(child: Text(text ?? '', style: f)),
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
