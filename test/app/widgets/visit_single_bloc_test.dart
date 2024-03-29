import 'package:city_go/app/widgets/visit_place_single/bloc/bloc.dart';
import 'package:city_go/data/core/localization_constants.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:city_go/domain/entities/future_response.dart';
import 'package:city_go/domain/entities/lat_lng.dart';
import 'package:city_go/domain/entities/profile/profile.dart';
import 'package:city_go/domain/entities/profile/user.dart';
import 'package:city_go/domain/repositories/visit_place/place_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'visit_single_bloc_test.mocks.dart';

@GenerateMocks([PlaceRepository, ProfileStorage])
void main() {
  final user = InAppUser(userName: 'name', accessToken: 'token', userId: 1);
  final imageSrc = ImageSrc.fromJson({
    'title': 'some title',
    'description': 'Some description',
    'image': '/src/image.jpg',
  });
  final place = FullVisitPlace(
    id: 1234,
    type: PlaceType.Museums,
    title: 'Ярославский музей-заповедник',
    description: 'description very big',
    generalInfo: 'Some general info',
    rating: 4.7,
    logo: imageSrc!.path,
    imageSrc: [imageSrc],
    latLng: LatLng(47.23452, 25.32612),
    objectWebSite: 'http://somesite.ru',
    workTime: 'Пн-пт 10:00-18:00, Сб-Вс выходной',
    objectAddress: 'Pushkina-Kolotushkina',
    audioSrc: '/audio/1.mp3',
  );

  late MockProfileStorage storage;
  late MockPlaceRepository repository;
  // ignore: close_sinks
  late VisitSingleBloc bloc;

  setUp(() {
    storage = MockProfileStorage();
    repository = MockPlaceRepository();
    bloc = VisitSingleBloc(
      storage: storage,
      repository: repository,
      id: place.id,
    );
  });

  test(
    'должен быть инициализирован с состоянием по-умолчанию',
    () async {
      // assert
      expect(bloc.state, VisitSingleBlocEmptyState());
    },
  );

  group('VisitSingleBlocLoadEvent', () {
    test(
      'должен завершиться с ошибкой, когда пользователь не авторизован',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile());

        // act
        bloc.add(VisitSingleBlocLoadEvent());
        await expectLater(
          bloc.stream,
          emitsInOrder([VisitSingleBlocDataState(null, USER_NOT_AUTH)]),
        );

        // assert
        verify(storage.profile);
        verifyNever(
          repository.getConcretePlace(
              id: anyNamed('id'), token: anyNamed('token')),
        );
      },
    );

    test(
      'должен завершиться с ошибкой, что нет интернета',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getConcretePlace(
              id: anyNamed('id'), token: anyNamed('token')),
        ).thenAnswer((_) => Future.value(FutureResponse.fail(NO_INTERNET)));
        // act
        bloc.add(VisitSingleBlocLoadEvent());
        await expectLater(
          bloc.stream,
          emitsInOrder([VisitSingleBlocDataState(null, NO_INTERNET)]),
        );

        // assert
        verify(storage.profile);
        verify(
          repository.getConcretePlace(id: place.id, token: user.accessToken),
        );
      },
    );

    test(
      'должен завершить загрузку успешно',
      () async {
        // arrange
        when(storage.profile).thenReturn(Profile(user: user));
        when(
          repository.getConcretePlace(
              id: anyNamed('id'), token: anyNamed('token')),
        ).thenAnswer((_) => Future.value(FutureResponse.success(place)));

        // act
        bloc.add(VisitSingleBlocLoadEvent());
        await expectLater(
          bloc.stream,
          emitsInOrder([VisitSingleBlocDataState(place)]),
        );

        // assert
        verify(storage.profile);
        verify(
          repository.getConcretePlace(id: place.id, token: user.accessToken),
        );
        expect(bloc.place, place);
      },
    );
  });
}
