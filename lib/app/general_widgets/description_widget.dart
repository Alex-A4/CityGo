import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

/// Виджет, содержащий описание к какому-то объекту, используется вместе с
/// [DraggableScrollableSheet].
class DescriptionWidget extends StatelessWidget {
  final String description;
  final ScrollController controller;
  final double minHeight;

  DescriptionWidget({
    Key key,
    @required this.description,
    @required this.minHeight,
    this.controller,
  })  : assert(description != null && minHeight != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.keyboard_arrow_up_outlined,
                size: 30,
                color: orangeColor,
              ),
            ),
            Text(
              'Описание',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'AleGrey',
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'MontserRat',
              ),
            ),
          ],
        ),
      ),
      color: Colors.white,
    );
  }
}
