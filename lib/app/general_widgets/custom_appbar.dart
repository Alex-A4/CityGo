import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

class CityAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget bottom;
  final Widget title;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;

  @override
  final Size preferredSize;

  CityAppBar({
    Key key,
    this.bottom,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  })  : preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return AppBar(
      iconTheme: IconThemeData(color: lightGrey),
      textTheme: theme,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: actions,
      bottom: bottom,
      elevation: 10,
      brightness: Brightness.dark,
      centerTitle: true,
    );
  }
}
