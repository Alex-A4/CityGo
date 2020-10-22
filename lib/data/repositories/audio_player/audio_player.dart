import 'dart:async';
import 'dart:io' as io;

import 'package:audio_service/audio_service.dart';
import 'package:city_go/data/repositories/audio_player/player_task.dart';
import 'package:city_go/data/storages/profile_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'player_data.dart';

abstract class CityAudioPlayer {
  Future<void> pausePlayer();

  Future<void> startPlayer(String url);

  Future<void> continuePlayer();

  Future<void> dispose();

  Future<void> closePlayer();

  Future<void> seek(Duration pos);

  PlayerStatus get playerStatus;

  Stream<PlayerStatus> get playerStatusStream;
}

class CityAudioPlayerImpl extends BackgroundAudioTask
    implements CityAudioPlayer {
  final ProfileStorage storage;
  CityPlayerBackgroundTask task;

  final AudioPlayer player = AudioPlayer();
  StreamSubscription playerSubscription;

  PlayerStatus _status = PlayerClosed();
  StreamController<PlayerStatus> _statusController =
      StreamController.broadcast();

  set status(PlayerStatus s) {
    _status = s;
    _statusController.add(s);
  }

  /// Длительность активного аудио
  Duration currentDuration;

  CityAudioPlayerImpl(this.storage) {
    task = CityPlayerBackgroundTask(this);
  }

  @override
  Future<void> pausePlayer() async {
    await player.pause();
    status = PlayerPause();
  }

  @override
  Future<void> continuePlayer() async {
    await player.play();
  }

  @override
  Future<void> startPlayer(String url) async {
    final user = storage.profile.user;
    if (user == null) return;
    status = PlayerLoading();
    currentDuration = await player.setUrl(url, headers: <String, String>{
      io.HttpHeaders.authorizationHeader: 'Token ${user.accessToken}',
    });

    if (playerSubscription == null)
      playerSubscription = player.positionStream
          .listen((d) => status = PlayerData(currentDuration, d));
    await continuePlayer();
  }

  @override
  Future<void> dispose() async {
    playerSubscription?.cancel();
    await player.dispose();
    _statusController.close();
  }

  @override
  Future<void> closePlayer() async {
    await pausePlayer();
    status = PlayerClosed();
  }

  @override
  PlayerStatus get playerStatus => _status;

  @override
  Stream<PlayerStatus> get playerStatusStream => _statusController.stream;

  @override
  Future<void> seek(Duration pos) async {
    await player.seek(pos);
  }
}
