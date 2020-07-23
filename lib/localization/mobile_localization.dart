import 'dart:ui';

import 'package:flutter/services.dart';
import 'dart:convert' show JsonCodec;
import 'abstract_localization.dart';

class MobileLocalization extends CityGoLocalization {
  MobileLocalization(Locale locale) : super(locale);

  @override
  Future<Map<String, dynamic>> load() async {
    var json = await rootBundle.loadString('assets/localization/$locale.json');
    return JsonCodec().decode(json);
  }
}
