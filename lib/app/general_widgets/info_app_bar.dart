import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/adaptive_button.dart';
import 'package:flutter/material.dart';

/// Информационный бар, который содержит только заголовок и кнопку назад
class InfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  InfoAppBar({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline6;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 16),
        child: Row(
          children: [
            AdaptiveButton.orangeTransparent(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
            SizedBox(width: 20),
            Expanded(
              child:
                  AutoSizeText(title, style: style, textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => size;

  static Size get size => Size.fromHeight(kToolbarHeight + 20);
}
