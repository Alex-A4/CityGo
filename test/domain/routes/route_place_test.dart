import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:city_go/domain/entities/routes/route_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'должен извлечь данные из JSON объекта',
    () async {
      // arrange
      final json = {
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
      };

      // act
      final routePlace = RoutePlace.fromJson(json);

      // assert
      expect(routePlace.id, json['id']);
      expect(routePlace.name, json['name']);
      expect(routePlace.workTime, json['workTime']);
      expect(routePlace.rating, json['rating']);
      expect(routePlace.objectAddress, json['address']);
      expect(routePlace.objectWebSite, json['website']);
      expect(routePlace.type, PlaceType.values[json['type']]);
      expect(routePlace.generalInfo, json['general']);
    },
  );
}
