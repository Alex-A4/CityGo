import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/custom_dialog.dart';
import 'package:city_go/app/general_widgets/rating_dialog.dart';
import 'package:city_go/app/general_widgets/rating_widget.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/repositories/audio_player/audio_player.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final infoStyle = style.copyWith(
      decoration: TextDecoration.none,
      fontSize: 16,
      fontFamily: 'Jost',
      fontWeight: FontWeight.w400,
    );

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icons.map_rounded,
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
              TextButton(
                onPressed: () {
                  print('ОБЩАЯ ИНФА');
                },
                child: AutoSizeText(context.localization(GENERAL_INFO),
                    style: style),
              ),
              SizedBox(height: 30),
              getInfoRow('assets/images/time.png', place.workTime, infoStyle),
              SizedBox(height: 5),
              getInfoRow(
                  'assets/images/place.png', place.objectAddress, infoStyle),
              SizedBox(height: 5),
              getInfoRow(
                'assets/images/web-site.png',
                place.objectWebSite,
                infoStyle.copyWith(decoration: TextDecoration.underline),
                launchWebSite,
              ),
              SizedBox(height: 50),
              RatingWidget(
                rating: place.rating,
                onTap: (context) {
                  Navigator.of(context).push(
                    DialogRoute(builder: (_) => RatingDialog()),
                  );
                },
              ),
              SizedBox(height: bottomSize + 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> launchWebSite() async {
    if (place.objectWebSite.isNotEmpty &&
        await canLaunch(place.objectWebSite)) {
      try {
        await launch(place.objectWebSite);
      } catch (_) {}
    }
  }

  Widget getInfoRow(String imagePath, String text, TextStyle sub2,
      [Function onTap]) {
    final child = Row(
      children: [
        Image.asset(imagePath, height: 30, fit: BoxFit.contain),
        SizedBox(width: 10),
        Expanded(child: AutoSizeText(text ?? '', style: sub2)),
      ],
    );
    if (onTap == null) return child;
    return InkWell(
      child: child,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget getIconWithSub(
      IconData icon, Function onTap, String subtitle, TextStyle sub2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AdaptiveButton.orangeTransparent(icon: icon, onTap: onTap),
        SizedBox(height: 10),
        AutoSizeText(
          subtitle.toUpperCase(),
          style: sub2.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
