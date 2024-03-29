import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/custom_dialog.dart' as d;
import 'package:city_go/app/general_widgets/rating_dialog.dart';
import 'package:city_go/styles/styles.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/app/widgets/visit_place_list/ui/rating_button.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Виджет-карточка, отображающий краткую инфомрацию об объекте-месте, куда
/// можно сходить.
class VisitItem extends StatelessWidget {
  final ClippedVisitPlace place;
  final HttpClient client;
  final PlaceRepository placeRepository;
  final double height;

  VisitItem({
    Key? key,
    required this.place,
    required this.height,
    required this.client,
    required this.placeRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 150),
      margin: EdgeInsets.only(bottom: 5),
      height: height - 5,
      decoration: BoxDecoration(
        image: place.logo == null
            ? null
            : DecorationImage(
                image: NetworkImage(client.getMediaPath(place.logo!)),
                fit: BoxFit.cover,
              ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.black26,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AutoSizeText(
                    place.name.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AutoSizeText(
                    context.localization(WORK_TIME).toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      color: lightGrey,
                      fontFamily: 'Jost',
                    ),
                  ),
                  AutoSizeText(
                    place.workTime,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: lightGrey,
                      fontFamily: 'Jost',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RatingButton(
                    rating: place.rating,
                    onTap: (context) {
                      Navigator.of(context).push(d.DialogRoute(
                        builder: (_) =>
                            RatingDialog(rateFunction: rateFunction),
                      ));
                    },
                  ),
                  Expanded(child: Container()),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.white38),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white, width: 5),
                      )),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(VISIT_SINGLE, arguments: place),
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
          ],
        ),
      ),
    );
  }

  Future<FutureResponse<dynamic>>? rateFunction(int value) {
    final user = sl<ProfileStorage>().profile.user;
    if (user == null) return null;

    return placeRepository.ratePlace(
      value: value,
      placeId: place.id,
      token: user.accessToken!,
      userId: user.userId!,
    );
  }
}
