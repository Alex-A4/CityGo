import 'package:city_go/domain/entities/lat_lng.dart';
import 'package:city_go/domain/entities/routes/route.dart';
import 'package:city_go/domain/entities/routes/route_clipped.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'должен извлечь обрезанную модель из JSON',
    () async {
      // arrange
      final json = {
        'id': 123,
        'title': 'Some title',
        'rating': 3.1,
        'length': 2.1,
        'logo': '/src/image.jpg',
      };

      // act
      final route = RouteClipped.fromJson(json);

      // assert
      expect(route.id, json['id']);
      expect(route.title, json['title']);
      expect(route.rating, json['rating']);
      expect(route.length, json['length']);
      expect(route.logo, json['logo']);
    },
  );

  test(
    'должен создать объект из JSON',
    () async {
      // arrange
      final json = <String, dynamic>{
        'id': 123,
        'title': 'Some title',
        'description': 'Some description',
        'rating': 3.1,
        'length': 2.1,
        'go_time': '1 час, 5 минут',
        'general': 'Some general info',
        'audio': '/src/someMP.mp3',
        'logo': '/src/image.jpg',
        'parts': [
          {
            'lat': 41.512,
            'lng': 41.42,
            'order': 1,
          },
        ],
        'places': [
          {
            'id': 10,
            'name': 'Место',
            'workTime': 'пн-вт, 9:00-18:00',
            'rating': 4.1,
            'address': 'Улица Пушкина',
            'website': 'http://sdfsd.ru',
            'type': 1,
            'general': 'Какая-то инфа',
            'coords': {
              'lat': 23.1252,
              'lng': 52.2512,
            }
          }
        ],
      };

      // act
      final route = Route.fromJson(json);

      // assert
      expect(route.id, json['id']);
      expect(route.title, json['title']);
      expect(route.description, json['description']);
      expect(route.rating, json['rating']);
      expect(route.goTime, json['go_time']);
      expect(route.generalInfo, json['general']);
      expect(route.audio, json['audio']);
      expect(route.cords.length, json['parts'].length);
      expect(route.routePlaces.length, json['places'].length);
      expect(route.logo, json['logo']);
    },
  );

  test(
    'должен отсортировать координаты маршрута',
    () async {
      // arrange
      final route = Route.fromJson({
        'id': 0,
        'parts': [
          {'order': 3, 'lat': 33.0, 'lng': 0.0},
          {'order': 1, 'lat': 31.0, 'lng': 0.0},
          {'order': 2, 'lat': 32.0, 'lng': 0.0},
        ]
      });

      // act
      var sorted = route.sortedPoints;

      // assert
      expect(
        sorted,
        equals([LatLng(31.0, 0.0), LatLng(32.0, 0.0), LatLng(33.0, 0.0)]),
      );
    },
  );
}
