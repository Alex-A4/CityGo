import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/app/widgets/visit_place_list/ui/rating_button.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

class PlaceDialog extends StatelessWidget {
  final FullVisitPlace place;
  final HttpClient client;

  PlaceDialog({Key key, @required this.place})
      : this.client = sl(),
        assert(place != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(minWidth: 300, maxHeight: 350),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: place.logo == null
              ? null
              : DecorationImage(
                  image: NetworkImage(client.getMediaPath(place.logo)),
                  fit: BoxFit.cover,
                ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black26,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveButton.orangeTransparent(
                          icon: Icons.close,
                          padding: 1,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(height: 5),
                        RatingButton(rating: place.rating),
                      ],
                    ),
                    Expanded(
                      child: AutoSizeText(
                        place.name.toUpperCase(),
                        style: theme.headline4,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: orangeColor, height: 1, thickness: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: AutoSizeText(
                          context.localization('general_info'),
                          style: theme.subtitle2.copyWith(
                              fontFamily: 'MontserRat',
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          place.generalInfo,
                          style: theme.bodyText1.copyWith(fontFamily: 'Jost'),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/time.png',
                              height: 30, fit: BoxFit.contain),
                          SizedBox(width: 10),
                          Expanded(
                              child: AutoSizeText(
                            place.workTime,
                            style: theme.bodyText1.copyWith(fontFamily: 'Jost'),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              FlatButton(
                color: Colors.white38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white, width: 5),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(VISIT_SINGLE, arguments: place);
                },
                child: AutoSizeText(
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
        ),
      ),
    );
  }
}
