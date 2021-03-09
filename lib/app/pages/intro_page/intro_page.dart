import 'package:city_go/app/navigator/router.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

/// Вступительный экран, содержащий анимацию.
/// После завершения анимации, переходит на главную страницу.
class IntroPage extends StatelessWidget {
  IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 250),
          margin: EdgeInsets.only(left: 50),
          child: FlareActor(
            'assets/flare/gid.flr',
            callback: (_) {
              Navigator.of(context).pushReplacementNamed(ROOT);
              Navigator.of(context).pop();
            },
            animation: 'Animations',
            alignment: Alignment.center,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
