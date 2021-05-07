import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Виджет для получения токена авторизации через VK OAuth.
/// При получении корректного запроса авторизации, возвращает словарь
/// с данными:
/// access_token - токен доступа
/// expires_in - время окончания (0) для нашего
/// user_id - идентификатор пользователя.
class VkLoginWidget extends StatelessWidget {
  final url = 'https://oauth.vk.com/authorize?client_id=7847249&' +
      'display=page&scope=65538&response_type=token&v=5.124';

  VkLoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: url,
        onPageFinished: (url) {
          Uri uri = Uri.parse(url);
          if ('${uri.host}${uri.path}' == 'oauth.vk.com/blank.html') {
            Navigator.of(context).pop(Uri.splitQueryString(uri.fragment));
          }
        },
      ),
    );
  }
}
