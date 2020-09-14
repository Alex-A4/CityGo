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
    return AppBar(
      backgroundColor: Colors.grey[800],
      iconTheme: IconThemeData(color: lightGrey),
      textTheme:
          TextTheme(headline6: TextStyle(color: lightGrey, fontSize: 20)),
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: actions,
      bottom: bottom,
      elevation: 10,
      centerTitle: true,
    );
  }
}
