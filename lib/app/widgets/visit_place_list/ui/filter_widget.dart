import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:city_go/localization/localization.dart';
import 'package:flutter/material.dart';

/// Виджет, отображающий кнопки для фильтрации
class FilterWidget extends StatelessWidget implements PreferredSizeWidget {
  final PlaceSortType activeType;
  final Function(PlaceSortType) onTap;

  FilterWidget({Key? key, required this.activeType, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SafeArea(
      top: false,
      child: Material(
        color: Colors.grey[800],
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.only(top: top, bottom: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 5),
                child: AutoSizeText(
                  context.localization(SORT_BY_WORD),
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...PlaceSortType.values.map((e) => sortButton(e, context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sortButton(PlaceSortType type, BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          type == activeType ? Colors.grey[500] : Colors.grey[100],
        ),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )),
      ),
      onPressed: () => onTap(type),
      child: AutoSizeText(
        context.localization(type.sortName),
        style: type == activeType ? selectedTextStyle : defaultTextStyle,
      ),
    );
  }

  static const defaultTextStyle =
      TextStyle(color: Color(0xFF616161), fontFamily: 'AleGray', fontSize: 16);

  final selectedTextStyle = defaultTextStyle.copyWith(color: orangeColor);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 50);
}
