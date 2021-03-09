import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

/// Кастомный выпадающий вниз виджет. Основан на анимации и расширяет содержимое
/// в списке. Не использует Overlay.
/// Может использоваться либо в качестве кнопки, тогда необходимо указать [onTap],
/// либо в качестве расшияряющегося виджета, тогда нужно указать [body].
class CityDropDown extends StatefulWidget {
  final Widget head;
  final Widget? body;
  final GestureTapCallback? onTap;

  CityDropDown({
    Key? key,
    required this.head,
    this.body,
    this.onTap,
  })  : assert(
          (body != null && onTap == null) || (body == null && onTap != null),
          'body или onTap должны быть null, но не оба вместе',
        ),
        super(key: key);

  @override
  _CityDropDownState createState() => _CityDropDownState();
}

class _CityDropDownState extends State<CityDropDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    if (widget.body != null) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: ListTile(
            onTap: widget.onTap ??
                () {
                  if (isExpanded)
                    _controller.reverse();
                  else
                    _controller.forward();
                  setState(() => isExpanded = !isExpanded);
                },
            leading: icon,
            title: widget.head,
          ),
        ),
        if (widget.body != null)
          SizeTransition(
            sizeFactor: _animation,
            child: widget.body,
          ),
      ],
    );
  }

  Widget get icon {
    IconData i;
    if (isExpanded)
      i = Icons.keyboard_arrow_down;
    else
      i = Icons.arrow_forward_ios;
    return Icon(i, color: orangeColor, size: isExpanded ? 30 : 20);
  }
}
