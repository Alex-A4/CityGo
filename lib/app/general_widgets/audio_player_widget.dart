import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/repositories/audio_player/audio_player.dart';
import 'package:city_go/data/repositories/audio_player/player_data.dart';
import 'package:flutter/material.dart';

class AudioPlayerOverlay {
  static OverlayState overlayState;
  static OverlayEntry _overlayEntry;
  static bool _isVisible = false;

  static void initPlayer(BuildContext context) {
    dispose();
    overlayState = Overlay.of(context);

    _overlayEntry = new OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          alignment: Alignment.bottomCenter,
          child: CityAudioPlayerWidget(player: sl()),
        );
      },
    );

    overlayState.insert(_overlayEntry);
    _isVisible = true;
  }

  static dispose() {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

class CityAudioPlayerWidget extends StatelessWidget {
  final CityAudioPlayer player;

  CityAudioPlayerWidget({Key key, @required this.player})
      : assert(player != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0x99000000),
      child: StreamBuilder<PlayerStatus>(
        stream: player.playerStatusStream,
        initialData: player.playerStatus,
        builder: (_, snap) {
          final status = snap.data;
          if (status is PlayerClosed) return Container(height: 0, width: 0);
          Widget leadingButton;
          String text = '';

          if (status is PlayerLoading) {
            leadingButton = CircularProgressIndicator();
          }

          if (status is PlayerPause) {
            text = 'pause';
            leadingButton = IconButton(
              color: Colors.white,
              icon: Icon(Icons.play_arrow),
              onPressed: () => player.continuePlayer(),
            );
          }

          if (status is PlayerData) {
            text =
                '${getTextDuration(status.currentPosition)}/${getTextDuration(status.trackDuration)}';
            leadingButton = IconButton(
              color: Colors.white,
              icon: Icon(Icons.pause_outlined),
              onPressed: () => player.pausePlayer(),
            );
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: 45,
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                leadingButton,
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.close),
                  onPressed: () => player.closePlayer(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String getTextDuration(Duration duration) {
    final inSeconds = duration.inSeconds;
    final minutes = inSeconds ~/ 60;
    final seconds = inSeconds % 60;
    return '$minutes:$seconds';
  }
}
