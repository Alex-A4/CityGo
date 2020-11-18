import 'package:city_go/app/navigator/router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

/// Вступительный экран, содержащий анимацию.
/// После завершения анимации, переходит на главную страницу.
class IntroPage extends StatefulWidget {
  IntroPage({Key key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/gid.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(ROOT);
              }
            });
            _controller
              ..duration = composition.duration
              ..forward();
          },
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
