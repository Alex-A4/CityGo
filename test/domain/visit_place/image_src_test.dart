import 'package:city_go/domain/entities/visit_place/image_src.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'должен корректно распарсить данные картинки из JSON',
    () async {
      // arrange
      final json = {
        'title': 'some title',
        'description': 'Some description',
        'image': '/src/image.jpg',
      };

      // act
      final image = ImageSrc.fromJson(json);

      // assert
      expect(image.path, json['image']);
      expect(image.description, json['description']);
      expect(image.title, json['title']);
    },
  );
}
