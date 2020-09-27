import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/rating_widget.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Виджет контента, который отображает информацию о маршруте
class SingleRouteContent extends StatelessWidget {
  final r.Route route;
  final double bottomSize;

  SingleRouteContent({Key key, @required this.route, @required this.bottomSize})
      : assert(route != null && bottomSize != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      () => print('VOLUME'),
                      context.localization(START_SOUND),
                    ),
                    getIconWithSub(
                      Icons.add_road,
                      () => Navigator.of(context)
                          .pushNamed(ROUTE_MAP_PAGE, arguments: route),
                      context.localization(CREATE_PATH),
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
              getInfoRow(LENGTH_WORD,
                  '${route.length} ${context.localization(KM_WORD)}', context),
              SizedBox(height: 20),
              getInfoRow(GO_TIME, '${route.goTime}', context),
              SizedBox(height: 50),
              RatingWidget(rating: route.rating),
              SizedBox(height: bottomSize + 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInfoRow(String titleCode, String text, BuildContext context) {
    final f = style.copyWith(
      decoration: TextDecoration.none,
      fontSize: 18,
      fontFamily: 'Jost',
    );
    return Row(
      children: [
        Text('${context.localization(titleCode)}:', style: f),
        SizedBox(width: 10),
        Text(text, style: f),
      ],
    );
  }

  Widget getIconWithSub(IconData icon, Function onTap, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdaptiveButton.orangeTransparent(icon: icon, onTap: onTap),
        SizedBox(height: 10),
        Text(subtitle.toUpperCase(), style: style),
      ],
    );
  }

  final style = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'AleGrey',
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
}
