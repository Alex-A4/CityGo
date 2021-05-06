import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/helpers/http_client.dart';
import 'package:city_go/data/helpers/network_checker.dart';
import 'package:city_go/data/repositories/visit_place/place_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'place_repo_test.mocks.dart';

@GenerateMocks([HttpClient, NetworkChecker])
void main() {
  final token = 'someToken';
  final defaultSort = PlaceSortType.Rating;
  final clippedJson = <dynamic>[
    {
      'id': 1234,
      'name': 'Ярославский музей-заповедник',
      'work_time': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
      'rating': 4.7,
      'type': 2,
      'logo': '/src/image.jpg',
    },
    {
      'id': 12872,
      'name': 'Ярославский заповедник 2',
      'work_time': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
      'rating': 4.7,
      'type': 2,
      'logo': '/src/image76.jpg',
    },
    {
      'id': 1224,
      'name': 'Парк у ДК. Нефтянник',
      'rating': 4.1,
      'type': 3,
      'logo': '/src/image2.jpg',
      'coords': {
        'lat': 52.12,
        'lng': 38.32,
      },
    },
  ];
  final fullJson = <String, dynamic>{
    'id': 1234,
    'name': 'Ярославский музей-заповедник',
    'work_time': 'Пн-пт 10:00-18:00, Сб-Вс выходной',
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

  late MockNetworkChecker checker;
  late MockHttpClient http;
  late PlaceRepository repository;

  setUp(() {
    http = MockHttpClient();
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
            Response(
              requestOptions: RequestOptions(path: ''),
              data: {'results': clippedJson},
              statusCode: 200,
            ),
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
              'type': 4,
              'sort': defaultSort.sortName,
              'offset': 0,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        expect(response.data!.length, 3);
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
            Response(
                requestOptions: RequestOptions(path: ''),
                data: {'results': clippedJson},
                statusCode: 200),
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
              'type': 4,
              'sort': PlaceSortType.Distance.sortName,
              'offset': 0,
              'limit': PlaceRepositoryImpl.count,
              'lat': latLng.latitude,
              'lng': latLng.longitude,
            },
            options: anyNamed('options'),
          ),
        );
        expect(response.data!.length, 3);
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
          (_) => Future.value(Response(
              requestOptions: RequestOptions(path: ''),
              data: fullJson,
              statusCode: 200)),
        );

        // act
        var response =
            await repository.getConcretePlace(id: 1234, token: token);

        // assert
        verify(http.get(PlaceRepositoryImpl.PLACE_PATH + '1234',
            options: anyNamed('options')));
        expect(response.data!.id, 1234);
      },
    );
  });

  group('getAllPlacesStream', () {
    test(
      'должен получить ошибку при загрузке, отдать ее и завершиться',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(false));

        // assert
        await expectLater(
          repository.getAllPlacesStream(token: token),
          emitsInOrder([
            FutureResponse<List<ClippedVisitPlace>>(NO_INTERNET, null),
            emitsDone,
          ]),
        );

        verify(checker.hasInternet);
      },
    );

    test(
      'должен загрузить данные и успешно вернуть их для каждого типа и с пагинацией',
      () async {
        // arrange
        when(checker.hasInternet).thenAnswer((_) => Future.value(true));

        when(
          http.get(any,
              queryParameters: anyNamed('queryParameters'),
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(
                requestOptions: RequestOptions(path: ''),
                data: {'results': []},
                statusCode: 200),
          ),
        );
        when(
          http.get(any,
              queryParameters: {
                'type': 2,
                'sort': PlaceSortType.Rating.sortName,
                'offset': 0,
                'limit': PlaceRepositoryImpl.count,
              },
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'results': [clippedJson[0]]
                },
                statusCode: 200),
          ),
        );
        when(
          http.get(any,
              queryParameters: {
                'type': 2,
                'sort': PlaceSortType.Rating.sortName,
                'offset': 1,
                'limit': PlaceRepositoryImpl.count,
              },
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'results': [clippedJson[1]]
                },
                statusCode: 200),
          ),
        );

        when(
          http.get(any,
              queryParameters: {
                'type': 3,
                'sort': PlaceSortType.Rating.sortName,
                'offset': 0,
                'limit': PlaceRepositoryImpl.count,
              },
              options: anyNamed('options')),
        ).thenAnswer(
          (_) => Future.value(
            Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'results': [clippedJson[2]]
                },
                statusCode: 200),
          ),
        );
        // assert
        await expectLater(
          repository.getAllPlacesStream(token: token),
          emitsInOrder([
            FutureResponse.success(
                [ClippedVisitPlace.fromJson(clippedJson[0])]),
            FutureResponse.success(
                [ClippedVisitPlace.fromJson(clippedJson[1])]),
            FutureResponse.success(
                [ClippedVisitPlace.fromJson(clippedJson[2])]),
            emitsDone,
          ]),
        );

        verify(checker.hasInternet);
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 2,
              'sort': PlaceSortType.Rating.sortName,
              'offset': 0,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 2,
              'sort': PlaceSortType.Rating.sortName,
              'offset': 1,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 2,
              'sort': PlaceSortType.Rating.sortName,
              'offset': 2,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 3,
              'sort': PlaceSortType.Rating.sortName,
              'offset': 0,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        verify(
          http.get(
            PlaceRepositoryImpl.PLACE_PATH,
            queryParameters: {
              'type': 3,
              'sort': PlaceSortType.Rating.sortName,
              'offset': 1,
              'limit': PlaceRepositoryImpl.count,
            },
            options: anyNamed('options'),
          ),
        );
        verify(http.get(
          PlaceRepositoryImpl.PLACE_PATH,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(6);
      },
    );
  });
}
