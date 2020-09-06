import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

/// Адаптивная кнопка, которую можно использовать как с иконкой, так и с помощью
/// кастомного виджета.
class AdaptiveButton extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final Color iconBorderColor;
  final Color backgroundColor;

  AdaptiveButton({
    Key key,
    @required this.child,
    @required this.onTap,
    this.iconBorderColor = orangeColor,
    this.backgroundColor = Colors.white,
  })  : assert(child != null),
        super(key: key);

  factory AdaptiveButton.orangeLight({
    Key key,
    @required IconData icon,
    @required Function onTap,
  }) =>
      AdaptiveButton(
        key: key,
        child: Icon(icon),
        onTap: onTap,
        iconBorderColor: orangeColor,
        backgroundColor: Colors.white,
      );

  factory AdaptiveButton.orangeTransparent({
    Key key,
    @required IconData icon,
    @required Function onTap,
  }) =>
      AdaptiveButton(
        key: key,
        child: Icon(icon),
        onTap: onTap,
        iconBorderColor: orangeColor,
        backgroundColor: Colors.transparent,
      );

  factory AdaptiveButton.widget({
    Key key,
    @required Widget widget,
    @required Function onTap,
    Color backgroundColor,
  }) =>
      AdaptiveButton(
        key: key,
        child: widget,
        onTap: onTap,
        backgroundColor: backgroundColor,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
        color: backgroundColor,
        border: Border.fromBorderSide(
          BorderSide(color: iconBorderColor, width: 2),
        ),
      ),
      child: IconButton(
        iconSize: 30,
        color: iconBorderColor,
        icon: child,
        onPressed: onTap,
      ),
    );
  }
}
