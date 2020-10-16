import 'package:equatable/equatable.dart';

/// Статус плеера, который позволяет реагировать UI на изменения
abstract class PlayerStatus extends Equatable {}

/// Статус, сообщающий, что плеер не активирован или был закрыт
class PlayerClosed extends PlayerStatus {
  @override
  List<Object> get props => [];
}

/// Статус, сообщающий, что плеер на паузе
class PlayerPause extends PlayerStatus {
  @override
  List<Object> get props => [];
}

/// Статус, сообщающий, что плеер загружает данные
class PlayerLoading extends PlayerStatus {
  @override
  List<Object> get props => [];
}

/// Статус, описывающая статус проигрывания плеера
class PlayerData extends PlayerStatus {
  /// Время длительности некоторого трека
  final Duration trackDuration;

  /// Текущая позиция плеера
  final Duration currentPosition;

  PlayerData(this.trackDuration, this.currentPosition);

  @override
  List<Object> get props => [trackDuration, currentPosition];
}
