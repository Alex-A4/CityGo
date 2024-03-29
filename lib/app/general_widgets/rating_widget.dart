import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/styles/styles.dart';
import 'package:flutter/material.dart';

/// Виджет рейтинга, который показывает 5 звезд и заполняет их в соответствии
/// с нужным количеством в строку.
class RatingWidget extends StatelessWidget {
  final double rating;

  /// Действие, которое позволяет перейти к простановке рейтинга
  final Function(BuildContext) onTap;
  static const top = 5;

  RatingWidget({Key? key, required this.rating, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Количество заполненных звезд
    final count = rating.floor();
    // Количество пустых звезд
    final empty = top - rating.ceil();
    final needHalf = count + empty < top;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...List.generate(count, (index) => getIcon(Icons.star)),
            if (needHalf) getIcon(Icons.star_half_sharp),
            ...List.generate(empty, (index) => getIcon(Icons.star_border)),
            AutoSizeText(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'AleGray',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getIcon(IconData icon) {
    return Icon(icon, color: orangeColor, size: 30);
  }
}
