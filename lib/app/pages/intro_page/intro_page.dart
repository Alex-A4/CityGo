import 'package:city_go/app/navigator/router.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

/// Вступительный экран, содержащий анимацию.
/// После завершения анимации, переходит на главную страницу.
class IntroPage extends StatelessWidget {
  IntroPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: FlareActor(
          'assets/flare/intro.flr',
          animation: 'Intro',
          callback: (_) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(ROOT);
          },
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
