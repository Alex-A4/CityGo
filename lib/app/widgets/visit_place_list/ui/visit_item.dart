import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/app/widgets/visit_place_list/ui/rating_button.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Виджет-карточка, отображающий краткую инфомрацию об объекте-месте, куда
/// можно сходить.
class VisitItem extends StatelessWidget {
  final ClippedVisitPlace place;
  final HttpClient client;
  final double height;

  VisitItem({
    Key key,
    @required this.place,
    @required this.height,
    @required this.client,
  })  : assert(place != null && height != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 150),
      height: height,
      decoration: BoxDecoration(
        image: place.logo == null
            ? null
            : DecorationImage(
                image: NetworkImage(client.getMediaPath(place.logo)),
                fit: BoxFit.cover,
              ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.black26,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Container()),
                RatingButton(rating: place.rating),
              ],
            ),
            Expanded(child: Container()),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        context.localization(WORK_TIME).toUpperCase(),
                        style: TextStyle(color: lightGrey, fontFamily: 'Jost'),
                      ),
                      Text(
                        place.workTime,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: lightGrey, fontFamily: 'Jost'),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  color: Colors.white38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.white, width: 5),
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(VISIT_SINGLE, arguments: place),
                  child: Text(
                    context.localization(DETAIL_WORD).toUpperCase(),
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 14,
                      color: Colors.white,
                      fontFamily: 'Jost',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
