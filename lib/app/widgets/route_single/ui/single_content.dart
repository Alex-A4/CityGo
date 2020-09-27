import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/rating_widget.dart';
import 'package:city_go/domain/entities/routes/route.dart' as r;
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
                    getIconWithSub(Icons.volume_up, () {
                      print('VOLUME');
                    }, 'Воспроизвести звук'),
                    getIconWithSub(Icons.add_road, () {
                      print('ROAD');
                    }, 'Построить маршрут'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              FlatButton(
                onPressed: () {
                  print('ОБЩАЯ ИНФА');
                },
                child: Text(
                  'Общая информация',
                  style: style.copyWith(fontSize: 18),
                ),
              ),
              SizedBox(height: 30),
              getInfoRow('Протяженность', '${route.length} km'),
              SizedBox(height: 20),
              getInfoRow('Время в пути', '${route.goTime}'),
              SizedBox(height: 50),
              RatingWidget(rating: route.rating),
              SizedBox(height: bottomSize + 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInfoRow(String titleCode, String text) {
    final f = style.copyWith(
      decoration: TextDecoration.none,
      fontSize: 18,
      fontFamily: 'Jost',
    );
    return Row(
      children: [
        Text('$titleCode:', style: f),
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
