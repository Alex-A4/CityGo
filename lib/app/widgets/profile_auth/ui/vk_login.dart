import 'package:city_go/app/general_widgets/city_web_view.dart';
import 'package:flutter/material.dart';

/// Виджет для получения токена авторизации через VK OAuth.
/// При получении корректного запроса авторизации, возвращает словарь
/// с данными:
/// access_token - токен доступа
/// expires_in - время окончания (0) для нашего
/// user_id - идентификатор пользователя.
class VkLoginWidget extends StatelessWidget {
  final url = 'https://oauth.vk.com/authorize?client_id=7610473&' +
      'display=page&scope=65538&response_type=token&v=5.124';

  VkLoginWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CityWebviewScaffold(
      appBar: AppBar(),
      url: url,
      clearCache: true,
      clearCookies: true,
      onUrlChanged: (u, c) {
        Uri uri = Uri.parse(u);
        if ('${uri.host}${uri.path}' == 'oauth.vk.com/blank.html') {
          Navigator.of(c).pop(Uri.splitQueryString(uri.fragment));
        }
      },
    );
  }
}
