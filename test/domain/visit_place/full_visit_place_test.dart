import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json1 = <String, dynamic>{
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'workTime': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
    'imgs': ['images/1.jpg'],
    'general': 'Some general info',
    'description': 'description very big',
    'audio': 'audio/1.mp4',
    'website': 'http://somesite.ru',
    'cords': {
      'lat': 47.23452,
      'lng': 25.32612,
    }
  };
  final json2 = <String, dynamic>{
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'workTime': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
    'imgs': ['images/1.jpg'],
    'general': 'Some general info',
    'description': 'description very big',
    'cords': {
      'lat': 47.23452,
      'lng': 25.32612,
    }
  };

  test(
    'должен создать объект из json',
    () async {
      // act
      var place = FullVisitPlace.fromJson(json1);

      // assert
      expect(place.id, json1['id']);
      expect(place.name, json1['name']);
      expect(place.rating, json1['rating']);
      expect(place.workTime, json1['workTime']);
      expect(place.description, json1['description']);
      expect(place.objectAddress, json1['address']);
      expect(place.objectWebSite, json1['website']);
      expect(place.generalInfo, json1['general']);
      expect(place.audioSrc, json1['audio']);
      expect(place.imageSrc, json1['imgs']);
      expect(place.latLng.latitude, json1['cords']['lat']);
      expect(place.latLng.longitude, json1['cords']['lng']);
    },
  );

  test(
    'должен создать объект из json, где не указан сайт и аудио',
        () async {
      // act
      var place = FullVisitPlace.fromJson(json2);

      // assert
      expect(place.id, json2['id']);
      expect(place.name, json2['name']);
      expect(place.rating, json2['rating']);
      expect(place.workTime, json2['workTime']);
      expect(place.description, json2['description']);
      expect(place.objectAddress, json2['address']);
      expect(place.objectWebSite, null);
      expect(place.generalInfo, json2['general']);
      expect(place.audioSrc, null);
      expect(place.imageSrc, json2['imgs']);
      expect(place.latLng.latitude, json2['cords']['lat']);
      expect(place.latLng.longitude, json2['cords']['lng']);
    },
  );
}
