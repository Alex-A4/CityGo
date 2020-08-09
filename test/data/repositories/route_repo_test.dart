import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/data/repositories/routes/route_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNetworkChecker extends Mock implements NetworkChecker {}

class MockClient extends Mock implements HttpClient {}

void main() {
  final clippedRoute = <String, dynamic>{
    'id': 123,
    'title': 'Some title',
    'rating': 3.1,
    'length': 2.1,
    'image': {
      'title': 'some title',
      'description': 'Some description',
      'image': '/src/image.jpg',
    },
  };
  final id = 123;
  final route = <String, dynamic>{
    'id': 123,
    'title': 'Some title',
    'description': 'Some description',
    'rating': 3.1,
    'length': 2.1,
    'goTime': '1 час, 5 минут',
    'general': 'Some general info',
    'audio': '/src/someMP.mp3',
    'image': {
      'title': 'some title',
      'description': 'Some description',
      'image': '/src/image.jpg',
    },
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

  final token = 'token';
  final offset = 0;

  MockNetworkChecker checker;
  MockClient http;
  RouteRepository repository;

  setUp(() {
    checker = MockNetworkChecker();
    http = MockClient();

    repository = RouteRepositoryImpl(http, checker);
  });

  group('getRoutes', () {
    test(
      'должен завершиться с ошибкой, что нет интернета',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // act
        final response =
            await repository.getRoutes(token: token, offset: offset);

        // assert
        verify(checker.hasInternet);
        expect(response.errorCode, NO_INTERNET);
      },
    );

    test(
      'должен вернуть результат успешно',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          http.get(any,
              queryParameters: anyNamed('queryParameters'),
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(data: [clippedRoute], statusCode: 200),
          ),
        );

        // act
        final response =
            await repository.getRoutes(token: token, offset: offset);

        // assert
        verify(checker.hasInternet);
        verify(http.get(
          RouteRepositoryImpl.ROUTE_PATH,
          queryParameters: {'offset': offset},
          options: anyNamed('options'),
        ));

        expect(response.data.length, 1);
      },
    );
  });

  group('getRoute', () {
    test(
      'должен завершиться с ошибкой, что нет интернета',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // act
        final response = await repository.getRoute(id: id, token: token);

        // assert
        verify(checker.hasInternet);
        expect(response.errorCode, NO_INTERNET);
      },
    );

    test(
      'должен вернуть объект с данными',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));
        when(
          http.get(any,
              options: anyNamed('options'),
              queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) => Future.value(Response(data: route, statusCode: 200)),
        );

        // act
        final response = await repository.getRoute(id: id, token: token);

        // assert
        verify(checker.hasInternet);
        verify(http.get(
          RouteRepositoryImpl.ROUTE_PATH + '$id',
          options: anyNamed('options'),
        ));
        expect(response.data.id, id);
      },
    );
  });
}
