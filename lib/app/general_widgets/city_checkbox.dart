import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:flutter/material.dart';

/// Кастомный радиобокс, который реализует переключение между группой значений.
class CityRadioBox<T> extends StatelessWidget {
  final ValueChanged<T> onChanged;
  final T value;
  final Widget title;
  final T groupValue;

  CityRadioBox({
    Key key,
    @required this.onChanged,
    @required this.value,
    @required this.title,
    @required this.groupValue,
  })  : assert(onChanged != null && title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: title, flex: 3),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400], width: 2),
                ),
                child: SizedBox(
                  child: Icon(
                    Icons.check,
                    color: value == groupValue ? orangeColor : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(child: Container(), flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет, который реализует список для радио-кнопок.
/// [values] и [titles] должны соответствовать друг другу.
/// [initValue] используется для начальной инициализации
class CityGroupRadioBox<T> extends StatefulWidget {
  final List<T> values;
  final List<Widget> titles;
  final T initValue;
  final ValueChanged<T> onChanged;

  CityGroupRadioBox({
    Key key,
    @required this.values,
    @required this.onChanged,
    @required this.initValue,
    @required this.titles,
  })  : assert(values != null &&
            onChanged != null &&
            initValue != null &&
            titles != null),
        assert(values.length == titles.length),
        super(key: key);

  @override
  _CityGroupRadioBoxState<T> createState() => _CityGroupRadioBoxState<T>();
}

class _CityGroupRadioBoxState<T> extends State<CityGroupRadioBox> {
  T currentValue;

  @override
  void initState() {
    currentValue = widget.initValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (int i = 0; i < widget.values.length; i++) {
      children.add(CityRadioBox<T>(
        value: widget.values[i],
        groupValue: currentValue,
        title: widget.titles[i],
        onChanged: updateValue,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...children],
    );
  }

  void updateValue(T value) {
    if (value != currentValue) {
      setState(() => currentValue = value);
      widget.onChanged(value);
    }
  }
}
