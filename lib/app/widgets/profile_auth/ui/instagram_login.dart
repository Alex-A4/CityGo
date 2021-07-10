import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Виджет для получения токена авторизации через Instagram OAuth.
/// При получении корректного запроса авторизации, возвращает словарь
/// с данными:
/// !!!code - токен доступа
class InstagramWidget extends StatelessWidget {
  static const redirect = 'https://localhost:5000';
  final url = 'https://api.instagram.com/oauth/authorize?client_id=523284702248055&'
      'redirect_uri=$redirect&response_type=code&scope=user_profile,user_media';

  InstagramWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: url,
        onPageFinished: (url) {
          Uri uri = Uri.parse(url);
          if ('${uri.host}${uri.path}' == redirect) {
            Navigator.of(context).pop(Uri.splitQueryString(uri.fragment));
          }
        },
      ),
    );
  }
}
