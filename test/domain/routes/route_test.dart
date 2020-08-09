import 'package:city_go/domain/entities/routes/route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        'goTime': '1 час, 5 минут',
        'general': 'Some general info',
        'audio': '/src/someMP.mp3',
        'cords': [
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
            'cords': {
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
      expect(route.goTime, json['goTime']);
      expect(route.generalInfo, json['general']);
      expect(route.audio, json['audio']);
      expect(route.cords.length, json['cords'].length);
      expect(route.routePlaces.length, json['places'].length);
    },
  );
}
