import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

class MockNetworkChecker extends Mock implements NetworkChecker {}

class MockHttp extends Mock implements HttpClient {}

void main() {
  final token = 'someToken';
  final defaultSort = PlaceSortType.Rating;
  final clippedJson = <dynamic>[
    {
      'id': 1234,
      'name': 'Ярославский музей-заповедник',
      'workTime': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
      'rating': 4.7,
      'logo': '/src/image.jpg',
    },
    {
      'id': 1224,
      'name': 'Парк у ДК. Нефтянник',
      'rating': 4.1,
      'logo': '/src/image2.jpg',
    },
  ];
  final fullJson = <String, dynamic>{
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'workTime': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    'rating': 4.7,
    'logo': '/src/image2.jpg',
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
    'cords': {
      'lat': 47.23452,
      'lng': 25.32612,
    }
  };

  MockNetworkChecker checker;
  MockHttp http;
  PlaceRepository repository;

  setUp(() {
    http = MockHttp();
    checker = MockNetworkChecker();
    repository = PlaceRepositoryImpl(http, checker);
  });

  group('getPlaces', () {
    test(
      'должен завершиться с ошибкой, что нет интернета',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // act
        var response = await repository.getPlaces(
            placeType: PlaceType.ActiveRecreation,
            token: token,
            offset: 0,
            sortType: defaultSort);

        // assert
        verify(checker.hasInternet);
        expect(response.errorCode, NO_INTERNET);
      },
    );

    test(
      'должен сделать запрос к серверу и вернуться с результатом',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          http.get(any,
              queryParameters: anyNamed('queryParameters'),
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(data: {'results': clippedJson}, statusCode: 200),
          ),
        );

        // act
        var response = await repository.getPlaces(
            placeType: PlaceType.ActiveRecreation,
            token: token,
            offset: 0,
            sortType: defaultSort);

        // assert
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 3,
              'sort': defaultSort.sortName,
              'offset': 0,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        expect(response.data.length, 2);
      },
    );

    test(
      '''должен сделать запрос к серверу и вернуться с результатом сортировки
         по дистанции''',
      () async {
        // arrange
        final latLng = LatLng(57.0, 38.0);
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          http.get(any,
              queryParameters: anyNamed('queryParameters'),
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(data: {'results': clippedJson}, statusCode: 200),
          ),
        );


        // act
        var response = await repository.getPlaces(
          placeType: PlaceType.ActiveRecreation,
          token: token,
          offset: 0,
          sortType: PlaceSortType.Distance,
          latLng: latLng,
        );

        // assert
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 3,
              'sort': PlaceSortType.Distance.sortName,
              'offset': 0,
              'limit': PlaceRepositoryImpl.count,
              'lat': latLng.latitude,
              'lng': latLng.longitude,
            },
            options: anyNamed('options'),
          ),
        );
        expect(response.data.length, 2);
      },
    );
  });

  group('getConcretePlace', () {
    test(
      'должен завершиться с ошибкой, что нет интернета',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // act
        var response =
            await repository.getConcretePlace(id: 1234, token: token);

        // assert
        verify(checker.hasInternet);
        expect(response.errorCode, NO_INTERNET);
      },
    );

    test(
      'должен сделать запрос к серверу и вернуться с результатом',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(http.get(
          any,
          options: anyNamed('options'),
        )).thenAnswer(
          (_) => Future.value(Response(data: fullJson, statusCode: 200)),
        );

        // act
        var response =
            await repository.getConcretePlace(id: 1234, token: token);

        // assert
        verify(http.get(PlaceRepositoryImpl.PLACE_PATH + '1234',
            options: anyNamed('options')));
        expect(response.data.id, 1234);
      },
    );
  });
}
