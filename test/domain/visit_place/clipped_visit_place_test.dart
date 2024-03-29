import 'package:city_go/domain/entities/visit_place/clipped_visit_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json1 = {
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'work_time': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
    'logo': '/src/image.jpg',
  };

  final json2 = {
    'id': 1234,
    'name': 'Парк у ДК. Невтянник',
    'rating': 4.1,
  };

  test(
    'должна извлечь данные из json, когда время указано',
    () async {
      // act
      var place = ClippedVisitPlace.fromJson(json1);

      // assert
      expect(place.id, json1['id']);
      expect(place.name, json1['name']);
      expect(place.workTime, json1['work_time']);
      expect(place.rating, json1['rating']);
      expect(place.logo, json1['logo']);
    },
  );

  test(
    'должна извлечь данные из json, когда время не указано',
    () async {
      // act
      var place = ClippedVisitPlace.fromJson(json2);

      // assert
      expect(place.id, json2['id']);
      expect(place.name, json2['name']);
      expect(place.workTime, '');
      expect(place.rating, json2['rating']);
      expect(place.logo, isNull);
    },
  );
}
