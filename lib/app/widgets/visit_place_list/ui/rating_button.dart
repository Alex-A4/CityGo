import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

class RatingButton extends StatelessWidget {
  final double rating;

  RatingButton({Key key, @required this.rating})
      : assert(rating != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: orangeColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, color: Colors.white),
              Text(
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
