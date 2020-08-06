import 'package:equatable/equatable.dart';

/// Обрезанная модель объектов для посещения.
/// Используется в списке, который отображает места по категориям.
/// Данная модель является универсальной и подходит для описания любого объекта.
class ClippedVisitPlace extends Equatable {
  /// Идентификатор на сервере
  final int id;

  /// Заголовок, который описывает карточку
  final String name;

  /// Время работы объекта, может не содержать информации, например, для парков.
  /// Если время не указано, то это пустая строка
  final String workTime;

  /// Рейтинг объекта
  final double rating;

  ClippedVisitPlace(this.id, this.name, this.workTime, this.rating);

  /// Фабрика для извлечения данных из JSON
  factory ClippedVisitPlace.fromJson(Map<String, dynamic> json) {
    return ClippedVisitPlace(
      json['id'],
      json['name'],
      json['workTime'] ?? '',
      json['rating'],
    );
  }

  @override
  List<Object> get props => [id, name, workTime, rating];
}
