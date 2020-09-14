import 'package:flutter/material.dart';


/// Кастомная версия диалогового окна, которая позволяет отобразить какой-нибудь
/// виджет поверх с затемнённым экраном.
/// Должен использоваться в Navigator.push() с передачей билдера, который
/// построит содержимое диалога.
class DialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;

  DialogRoute({@required this.builder}) : assert(builder != null);

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'DialogRoute';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SafeArea(
      child: SizeTransition(
        sizeFactor: animation.drive(Tween(begin: 0.0, end: 1.0)),
        child: builder(context),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}
