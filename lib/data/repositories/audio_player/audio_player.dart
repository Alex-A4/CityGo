import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'player_data.dart';

abstract class CityAudioPlayer {
  Future<void> pausePlayer();

  Future<void> startPlayer(String url);

  Stream<PlayerStatus> get playerStream;
}

class CityAudioPlayerImpl extends BackgroundAudioTask
    implements CityAudioPlayer {
  final AudioPlayer player = AudioPlayer();
  Duration currentDuration;

  @override
  Future<void> pausePlayer() async {}

  @override
  Future<void> startPlayer(String url) async {
    currentDuration = await player.setUrl(url);
  }

  @override
  Stream<PlayerStatus> get playerStream => throw UnimplementedError();
}
