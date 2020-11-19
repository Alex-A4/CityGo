import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

/// Кнпока, позволяющая открыть простановку рейтинга для места.
class RatingButton extends StatelessWidget {
  final double rating;
  final Function(BuildContext) onTap;

  RatingButton({Key key, @required this.rating, @required this.onTap})
      : assert(rating != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: orangeColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onTap(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, color: Colors.white),
              AutoSizeText(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
