import 'package:equatable/equatable.dart';

/// Статус плеера, который позволяет реагировать UI на изменения
abstract class PlayerStatus extends Equatable {
  /// Время длительности некоторого трека
  final Duration? trackDuration;

  /// Текущая позиция плеера
  final Duration? currentPosition;

  PlayerStatus(this.trackDuration, this.currentPosition);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [trackDuration, currentPosition];
}

/// Статус, сообщающий, что плеер не активирован или был закрыт
class PlayerClosed extends PlayerStatus {
  PlayerClosed() : super(null, null);
}

/// Статус, сообщающий, что плеер на паузе
class PlayerPause extends PlayerStatus {
  PlayerPause(Duration? trackDuration, Duration? currentPosition)
      : super(trackDuration, currentPosition);
}

/// Статус, сообщающий, что плеер загружает данные
class PlayerLoading extends PlayerStatus {
  PlayerLoading(Duration? trackDuration, Duration? currentPosition)
      : super(trackDuration, currentPosition);
}

/// Статус, описывающая статус проигрывания плеера
class PlayerData extends PlayerStatus {
  PlayerData(Duration? trackDuration, Duration? currentPosition)
      : super(trackDuration, currentPosition);
}
