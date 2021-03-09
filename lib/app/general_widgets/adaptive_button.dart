import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

/// Адаптивная кнопка, которую можно использовать как с иконкой, так и с помощью
/// кастомного виджета.
class AdaptiveButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final Color iconBorderColor;
  final Color? backgroundColor;
  final double padding;
  final bool needBorder;
  static const iconSize = 30.0;

  AdaptiveButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.iconBorderColor = orangeColor,
    this.backgroundColor = Colors.white,
    this.padding = 5.0,
    this.needBorder = true,
  }) : super(key: key);

  factory AdaptiveButton.orangeLight({
    Key? key,
    required IconData icon,
    required GestureTapCallback onTap,
    padding: 5.0,
  }) =>
      AdaptiveButton(
        key: key,
        child: Icon(icon),
        onTap: onTap,
        padding: padding,
        iconBorderColor: orangeColor,
        backgroundColor: Colors.white,
      );

  factory AdaptiveButton.orangeTransparent({
    Key? key,
    required IconData icon,
    required GestureTapCallback? onTap,
    double padding = 5.0,
  }) =>
      AdaptiveButton(
        key: key,
        child: Icon(icon),
        onTap: onTap,
        padding: padding,
        iconBorderColor: orangeColor,
        backgroundColor: Colors.white24,
      );

  factory AdaptiveButton.widget({
    Key? key,
    required Widget widget,
    required GestureTapCallback? onTap,
    Color? backgroundColor,
    padding: 5.0,
  }) =>
      AdaptiveButton(
        key: key,
        padding: padding,
        child: widget,
        onTap: onTap,
        backgroundColor: backgroundColor,
      );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Color currentColor = onTap == null ? theme.disabledColor : iconBorderColor;

    return InkResponse(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          color: backgroundColor,
          border: !needBorder
              ? null
              : Border.fromBorderSide(
                  BorderSide(color: iconBorderColor, width: 2),
                ),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: IconTheme.merge(
            data: IconThemeData(size: iconSize, color: currentColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
