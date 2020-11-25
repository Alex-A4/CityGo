import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as math;

class RatingDialog extends StatefulWidget {
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  static const top = 5;
  static const backColor = Color(0xFFD0D0D0);
  int _currentRating = 0;
  int _needToSet = 0;
  final angle = 60.0;

  set currentRating(int value) {
    _needToSet = value;
    _controller.forward();
  }

  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
          _currentRating = _needToSet;
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, __) {
        // Количество пустых звезд
        final empty = top - _currentRating;

        return Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: backColor,
          child: Container(
            margin: EdgeInsets.all(15),
            constraints: BoxConstraints(maxWidth: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText('Вы здесь были?\nОцените место',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyText2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ...List.generate(_currentRating,
                        (index) => getIcon(Icons.star, index + 1)),
                    ...List.generate(
                        empty,
                        (index) => getIcon(
                            Icons.star_border, index + 1 + _currentRating)),
                  ],
                ),
                AdaptiveButton(
                  child: Icon(Icons.close, color: backColor),
                  backgroundColor: Colors.grey,
                  iconBorderColor: Colors.transparent,
                  padding: 1,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getIcon(IconData icon, int rating) {
    return GestureDetector(
      onTap: () => setState(() => currentRating = rating),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Transform(
          transform: Matrix4.identity()
            ..rotateY(math.radians(angle * _controller.value)),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}