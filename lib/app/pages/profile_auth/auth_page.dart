import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/app/widgets/profile_auth/bloc/bloc.dart';
import 'package:city_go/app/widgets/profile_auth/ui/auth_input.dart';
import 'package:city_go/app/widgets/profile_auth/ui/auth_login_button.dart';
import 'package:city_go/app/widgets/profile_auth/ui/instagram_login.dart';
import 'package:city_go/app/widgets/profile_auth/ui/login_extenral_button.dart';
import 'package:city_go/app/widgets/profile_auth/ui/vk_login.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

class AuthPage extends StatefulWidget {
  final ProfileBloc bloc;
  final bool isAuth;

  AuthPage({
    Key key = const Key('AuthPage'),
    required this.bloc,
    required this.isAuth,
  }) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  ProfileBloc get bloc => widget.bloc;

  bool get isAuth => widget.isAuth;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('AuthPageScaffold'),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        key: Key('AuthPageSafeArea'),
        child: Stack(
          key: Key('AuthPageStack'),
          fit: StackFit.expand,
          children: [
            Container(
              key: Key('AuthPageBackground'),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/profile_background.jpg'),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerLeft,
                ),
              ),
              child: Container(
                color: Color(0x5FFFA726),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: authField(context),
                ),
              ),
            ),
            Positioned(top: 5, left: 6, child: backButton(context)),
          ],
        ),
      ),
    );
  }

  Widget authField(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Container(), flex: 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText(
              context.localization(WELCOME_WORD),
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'Jost',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            Form(
              key: formKey,
              child: Column(
                children: [
                  AuthInput(
                    controller: loginController,
                    hintCode: YOUR_NAME,
                  ),
                  SizedBox(height: 14),
                  AuthInput(
                    controller: passwordController,
                    hintCode: YOUR_PASSWORD,
                    isPassword: true,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (isAuth) {
                  bloc.add(ProfileGoToLoginEvent());
                } else {
                  bloc.add(ProfileGoToAuthEvent());
                }
              },
              child: AutoSizeText(
                context.localization(isAuth ? HAVE_ACCOUNT : CREATE_ACCOUNT),
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(kSplashColor),
              ),
            ),
            SizedBox(height: 20),
            AuthLoginButton(
              isAuthState: isAuth,
              onTap: () {
                if (!formKey.currentState!.validate()) return;

                if (isAuth) {
                  bloc.add(ProfileAuthInternalEvent(
                    loginController.text,
                    passwordController.text,
                  ));
                } else {
                  bloc.add(ProfileLogInEvent(
                    loginController.text,
                    passwordController.text,
                  ));
                }
              },
            ),
            SizedBox(height: 20),
            AutoSizeText(
              context.localization(OR_WORD),
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Jost',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                LoginExternalButton(
                  imagePath: 'assets/images/vk.png',
                  onTap: (context) async {
                    final mapData = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => VkLoginWidget()),
                    );
                    print(mapData);
                    final user = mapData == null
                        ? null
                        : VKUser(externalToken: mapData['code']);
                    if (user != null) bloc.add(ProfileAuthExternalEvent(user));
                  },
                ),
                if (Platform.isAndroid)
                  LoginExternalButton(
                    imagePath: 'assets/images/google.png',
                    onTap: (context) {
                      print('google');
                    },
                  ),
                LoginExternalButton(
                  imagePath: 'assets/images/instagram.png',
                  onTap: (context) async {
                    final mapData = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => InstagramWidget()),
                    );
                    print(mapData);
                    final user = mapData == null
                        ? null
                        : VKUser(externalToken: mapData['code']);
                    if (user != null) bloc.add(ProfileAuthExternalEvent(user));
                  },
                ),
              ],
            ),
          ],
        ),
        Expanded(child: Container()),
      ],
    );
  }

  // Кнопка назад
  Widget backButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: kSplashColor,
        borderRadius: BorderRadius.circular(90),
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(90),
            color: Colors.transparent,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.black, width: 2),
            ),
          ),
          child: Icon(
            Icons.arrow_back,
            size: 40,
            color: Colors.orange[800],
          ),
        ),
      ),
    );
  }
}
