import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Карточка главной страницы, на которой описано тип мест или пеших маршрутов.
class PlaceTypeCard extends StatelessWidget {
  final String imagePath;
  final String nameCode;
  final Function onTap;
  final double height;

  PlaceTypeCard({
    Key key,
    @required this.imagePath,
    @required this.nameCode,
    @required this.onTap,
    @required this.height,
  })  : assert(imagePath != null && nameCode != null && onTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline4;

    return Container(
      constraints: BoxConstraints(minHeight: 150),
      margin: EdgeInsets.only(bottom: 3),
      height: height - 3,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: AutoSizeText(
            context.localization(nameCode),
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
