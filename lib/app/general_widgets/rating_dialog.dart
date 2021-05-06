import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:city_go/app/general_widgets/toast_widget.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

import 'package:vector_math/vector_math.dart' as math;

/// Асинхронный колбек для проставления оценкки
typedef RateFunction = Future<FutureResponse<dynamic>>? Function(int value);

class RatingDialog extends StatefulWidget {
  final RateFunction rateFunction;

  const RatingDialog({Key? key, required this.rateFunction}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  static const top = 5;
  static const backColor = Color(0xFFD0D0D0);
  int _currentRating = 0;
  int _displayRating = 0;
  final angle = 60.0;

  set currentRating(int value) {
    _currentRating = value;
    _controller.forward();
  }

  bool successVote = false;
  Future? successFuture;

  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
          _displayRating = _currentRating;
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

    if (successVote) {
      successFuture ??= Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: backColor,
        child: Container(
          margin: EdgeInsets.all(15),
          constraints: BoxConstraints(maxWidth: 250),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      context.localization('rate_success'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText2?.copyWith(fontSize: 20),
                    ),
                  ),
                ],
              ),
              Icon(Icons.check_box_outlined, size: 50, color: Colors.white),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, __) {
        // Количество пустых звезд
        final empty = top - _displayRating;

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
                Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        context.localization('rate_dialog_title'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyText2,
                      ),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ...List.generate(_displayRating,
                        (index) => getIcon(Icons.star, index + 1)),
                    ...List.generate(
                        empty,
                        (index) => getIcon(
                            Icons.star_border, index + 1 + _displayRating)),
                  ],
                ),
                TextButton(
                  style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all(orangeColor.withOpacity(0.6)),
                    backgroundColor: MaterialStateProperty.all(
                        isDisabled ? Colors.grey : Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
                  ),
                  onPressed: isDisabled
                      ? null
                      : () async {
                          final response =
                              await widget.rateFunction.call(_currentRating);
                          if (response?.hasError ?? false) {
                            CityToast.showToast(context, response!.errorCode!);
                            Navigator.of(context).pop();
                          } else {
                            setState(() => successVote = true);
                          }
                        },
                  child: Text(
                    context.localization('rate_word'),
                    style: theme.textTheme.bodyText2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get isDisabled => _currentRating == 0;

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
