import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Кнопка профиля, которая отображает текст "Зарегистрироваться" или "Войти"
class AuthLoginButton extends StatelessWidget {
  /// Флаг, обозначающий, какой текст нужно отобразить: регистрацию или вход.
  /// true - Зарегистрироваться, false - Войти
  final bool isAuthState;
  final GestureTapCallback onTap;

  AuthLoginButton({
    Key? key,
    required this.isAuthState,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xFFb5b5b5)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        )),
      ),
      onPressed: onTap,
      child: SizedBox(
        height: 53,
        width: 248,
        child: Center(
          child: AutoSizeText(
            isAuthState
                ? context.localization(AUTH_WORD)
                : context.localization(LOGIN_WORD),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
