import 'package:equatable/equatable.dart';

/// Объект изображения, который содержит все поля
class ImageSrc extends Equatable {
  final String path;
  final String description;
  final String title;

  ImageSrc(this.path, this.description, this.title);

  factory ImageSrc.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return ImageSrc(
      json['image'],
      json['description'],
      json['title'],
    );
  }

  @override
  List<Object> get props => [path, description, title];
}
