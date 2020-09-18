import 'dart:ui';

import 'package:city_go/app/general_widgets/ui_constants.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Текстовое поле для ввода логина/пароля для авторизации
class AuthInput extends StatefulWidget {
  final bool isPassword;
  final TextEditingController controller;

  final String hintCode;

  AuthInput({
    Key key,
    @required this.controller,
    this.isPassword = false,
    @required this.hintCode,
  })  : assert(controller != null && hintCode != null),
        super(key: key);

  @override
  _AuthInputState createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: orangeColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: 325, minHeight: 53, maxHeight: 53),
        child: Center(
          child: TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return context.localization(
                  widget.isPassword ? PASSWORD_NOT_EMPTY : LOGIN_NOT_EMPTY,
                );
              return null;
            },
            cursorColor: Colors.white,
            controller: widget.controller,
            obscureText: widget.isPassword,
            obscuringCharacter: '*',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Jost',
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              hintText: context.localization(widget.hintCode),
              contentPadding: EdgeInsets.symmetric(horizontal: 30),
            ),
          ),
        ),
      ),
    );
  }
}
