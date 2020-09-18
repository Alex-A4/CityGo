import 'package:flutter/material.dart';

/// Кнопка с картинкой для входа через внешние источники
class LoginExternalButton extends StatelessWidget {
  final String imagePath;
  final Function onTap;

  LoginExternalButton({
    Key key,
    @required this.imagePath,
    @required this.onTap,
  })  : assert(onTap != null && imagePath != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(90),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              color: Colors.grey[400],
            ),
            padding: EdgeInsets.all(10),
            width: 60,
            height: 60,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
