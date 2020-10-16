import 'package:audio_service/audio_service.dart';
import 'package:city_go/data/repositories/audio_player/audio_player.dart';

class CityPlayerBackgroundTask extends BackgroundAudioTask {
  final CityAudioPlayer player;

  CityPlayerBackgroundTask(this.player);

  @override
  onPlay() async {
    await player.continuePlayer();
    await AudioServiceBackground.setState(
      playing: true,
      controls: [MediaControl.pause],
      processingState: AudioProcessingState.ready,
    );
  }

  @override
  onPause() async {
    await player.pausePlayer();
    await AudioServiceBackground.setState(
      playing: false,
      controls: [MediaControl.play],
      processingState: AudioProcessingState.ready,
    );
  }

  @override
  onStart(Map<String, dynamic> params) async {
    await player.startPlayer(params['url']);
    await AudioServiceBackground.setState(
      playing: true,
      controls: [MediaControl.pause],
      processingState: AudioProcessingState.ready,
    );
  }

  @override
  onStop() async {
    await player.closePlayer();
    await super.onStop();
  }
}
