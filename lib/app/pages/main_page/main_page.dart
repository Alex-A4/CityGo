import 'package:city_go/app/general_widgets/custom_appbar.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/app/navigator/router.dart';
import 'package:city_go/app/widgets/main_page/place_type_card.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Главная страница, которая отображается по-умолчанию.
/// На ней находятся группы объектов/мест, куда пользователь может сходить.
class MainPage extends StatelessWidget {
  /// Список кодов названий, должен соответсовать порядку в [PlaceType].
  final nameCodes = [
    MUSEUMS_WORD,
    RESTAURANT_WORD,
    CATHEDRALS_WORD,
    ACTIVE_RECREATION_WORD,
    PARKS_WORD,
    PUBS_WORD,
    THEATRES_WORD,
    MALLS_WORD,
  ];
  final images = [
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
    'assets/images/profile_background.jpg',
  ];

  MainPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = (mq.size.height - kToolbarHeight - mq.padding.top) / 3;

    return Scaffold(
      backgroundColor: orangeColor,
      appBar: CityAppBar(
        title: Text(context.localization(YAROSLAVL_WORD)),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).pushNamed(PROFILE),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: nameCodes.length + 1,
        itemBuilder: (_, i) {
          if (i == 0)
            return PlaceTypeCard(
              imagePath: 'assets/images/profile_background.jpg',
              nameCode: PATHS_WORD,
              onTap: () => Navigator.of(context).pushNamed(ROUTE_LIST),
              height: height,
            );
          return PlaceTypeCard(
            key: Key(nameCodes[i - 1]),
            imagePath: images[i - 1],
            nameCode: nameCodes[i - 1],
            onTap: () => Navigator.of(context).pushNamed(
              VISIT_LIST,
              arguments: {
                'title': nameCodes[i - 1],
                'type': PlaceType.values[i - 1],
              },
            ),
            height: height,
          );
        },
      ),
    );
  }
}
