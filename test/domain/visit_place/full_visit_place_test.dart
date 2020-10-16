import 'package:city_go/domain/entities/visit_place/full_visit_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json1 = <String, dynamic>{
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'work_time': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
    'images': [
      {
        'title': 'some title',
        'description': 'Some description',
        'image': '/src/image.jpg',
      },
    ],
    'general': 'Some general info',
    'description': 'description very big',
    'audio': 'audio/1.mp4',
    'website': 'http://somesite.ru',
    'coords': {
      'lat': 47.23452,
      'lng': 25.32612,
    },
    'logo': '/src/image.jpg',
  };
  final json2 = <String, dynamic>{
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'work_time': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
    'images': [
      {
        'title': 'some title',
        'description': 'Some description',
        'image': '/src/image.jpg',
      },
    ],
    'general': 'Some general info',
    'description': 'description very big',
    'coords': {
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
      expect(place.workTime, json1['work_time']);
      expect(place.description, json1['description']);
      expect(place.objectAddress, '');
      expect(place.objectWebSite, json1['website']);
      expect(place.generalInfo, json1['general']);
      expect(place.audioSrc, json1['audio']);
      expect(place.imageSrc.length, json1['images'].length);
      expect(place.latLng.latitude, json1['coords']['lat']);
      expect(place.latLng.longitude, json1['coords']['lng']);
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
      expect(place.workTime, json2['work_time']);
      expect(place.description, json2['description']);
      expect(place.objectAddress, '');
      expect(place.objectWebSite, '');
      expect(place.generalInfo, json2['general']);
      expect(place.audioSrc, null);
      expect(place.imageSrc.length, json2['images'].length);
      expect(place.latLng.latitude, json2['coords']['lat']);
      expect(place.latLng.longitude, json2['coords']['lng']);
    },
  );
}
