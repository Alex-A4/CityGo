import 'package:flutter/material.dart';
import 'package:city_go/localization/localization.dart';

/// Класс, позволяющий показывать сообщения об ошибке в нижней части экрана,
/// использует контекст и идентификатор сообщения из локализации.
class CityToast {
  static GlobalKey<_CityToastToastWidgetState> _key = GlobalKey();
  static OverlayState overlayState;
  static OverlayEntry _overlayEntry;
  static bool _isVisible = false;
  static const animationDuration = 500;

  static BuildContext appContext;

  /// Отображение уведомления на контексте уровня приложения.
  /// [appContext] должен быть инициализирован или обновлен каждый раз, когда
  /// обновляется App виджет. Данный метод позволяет отображать уведомление
  /// из мест программы, где недоступен контекст, например, при обновлении токена.
  static void showToastAppLevel(String messageId) {
    if (appContext != null) showToast(appContext, messageId);
  }

  static void showToast(BuildContext context, String messageId) async {
    if (_isVisible) return;

    overlayState = Overlay.of(context);

    _overlayEntry = new OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 10,
                right: 10),
            child: _CityToastToastWidget(key: _key, messageId: messageId),
          ),
        );
      },
    );

    _isVisible = true;

    /// Показываем сообщение.
    overlayState.insert(_overlayEntry);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _key.currentState?.show());

    /// Спустя 2500 милисекунд прячем сообщение и удаляем его с Overlay.
    await Future.delayed(Duration(milliseconds: 2500));
    _key.currentState?.hide();
    await Future.delayed(Duration(milliseconds: animationDuration));
    dismiss();
  }

  static dismiss() {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

/// Виджет для показа сообщения об ошибке, позволяет анимировать его при показе
/// и удалении.
class _CityToastToastWidget extends StatefulWidget {
  final String messageId;

  _CityToastToastWidget({Key key, @required this.messageId}) : super(key: key);

  @override
  _CityToastToastWidgetState createState() => _CityToastToastWidgetState();
}

class _CityToastToastWidgetState extends State<_CityToastToastWidget> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
  }

  void show() => setState(() => opacity = 1.0);

  void hide() => setState(() => opacity = 0.0);

  @override
  Widget build(BuildContext context) {
    String message = '';
    try {
      message = context.localization(widget.messageId);
    } catch (e) {
      message = context.localization('unexpected_error');
    }
    return AnimatedOpacity(
      duration: Duration(milliseconds: CityToast.animationDuration),
      opacity: opacity,
      child: Material(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}
