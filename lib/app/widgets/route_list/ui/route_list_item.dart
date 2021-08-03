import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/styles/styles.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Карточка маршрута
class RouteItem extends StatelessWidget {
  final RouteClipped route;
  final HttpClient client = sl();

  RouteItem({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(ROUTE_SINGLE, arguments: route),
      child: Container(
        decoration: BoxDecoration(
          image: route.logo == null
              ? null
              : DecorationImage(
                  image: NetworkImage(client.getMediaPath(route.logo!)),
                  fit: BoxFit.cover,
                ),
        ),
        child: Container(
          color: Colors.black38,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(), flex: 2),
              AutoSizeText(
                context.localization(ROUTE_WORD),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AutoSizeText(
                route.title,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'MontserRat',
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AutoSizeText(
                      '${route.length.toString().replaceAll('.', ',')} ${context.localization(KILOMETERS_WORD)}',
                      style: TextStyle(
                        color: orangeColor,
                        fontFamily: 'Jost',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
