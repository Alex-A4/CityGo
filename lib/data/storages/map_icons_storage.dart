import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Хранилище иконок меток для карты. Загружает картинки из ассетов
/// один раз, в дальнейшем можно использовать без задержек.
abstract class MapIconsStorage {
  /// Получение списка картинок асинхронно.
  /// Скорее всего, к моменту вызова все картинки уже будут загружены и
  /// отдадутся мгновенно.
  Future<List<BitmapDescriptor>> get future;

  /// Вызов этой функции должен происходить в начале работы приложения, чтобы
  /// загрузить картинки.
  void startLoading();
}

class MapIconsStorageImpl extends MapIconsStorage {
  final Completer<List<BitmapDescriptor>> _completer = Completer();

  @override
  Future<List<BitmapDescriptor>> get future => _completer.future;

  @override
  void startLoading() {
    _completer.complete(_readBitmaps());
  }

  /// Чтение картинок асинхронно.
  Future<List<BitmapDescriptor>> _readBitmaps() async {
    final points = <BitmapDescriptor>[];

    for (int i = 0; i <= 2; i++) {
      var point = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty,
        'assets/images/points/point$i.bmp',
      );
      points.add(point);
    }

    return points;
  }
}
