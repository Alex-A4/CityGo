import 'package:city_go/domain/repositories/visit_place/clipped_visit_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json1 = {
    'id': 1234,
    'title': 'Ярославский музей-заповедник',
    'workTime': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
  };

  final json2 = {
    'id': 1234,
    'title': 'Парк у ДК. Невтянник',
    'rating': 4.1,
  };

  test(
    'должна извлечь данные из json, когда время указано',
    () async {
      // act
      var place = ClippedVisitPlace.fromJson(json1);

      // assert
      expect(place.id, json1['id']);
      expect(place.title, json1['title']);
      expect(place.workTime, json1['workTime']);
      expect(place.rating, json1['rating']);
    },
  );

  test(
    'должна извлечь данные из json, когда время не указано',
    () async {
      // act
      var place = ClippedVisitPlace.fromJson(json2);

      // assert
      expect(place.id, json2['id']);
      expect(place.title, json2['title']);
      expect(place.workTime, '');
      expect(place.rating, json2['rating']);
    },
  );
}
