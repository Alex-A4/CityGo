import 'package:auto_size_text/auto_size_text.dart';
import 'package:city_go/data/core/service_locator.dart';
import 'package:city_go/data/repositories/audio_player/audio_player.dart';
import 'package:city_go/data/repositories/audio_player/player_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
          String text =
              '${getTextDuration(status.currentPosition)}/${getTextDuration(status.trackDuration)}';
          Duration current = status.currentPosition;
          Duration track = status.trackDuration;

          if (status is PlayerLoading) {
            leadingButton = CircularProgressIndicator();
          }

          if (status is PlayerPause) {
            leadingButton = IconButton(
              color: Colors.white,
              icon: Icon(Icons.play_arrow),
              onPressed: () => player.continuePlayer(),
            );
          }

          if (status is PlayerData) {
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
                if (track != null && current != null)
                  Expanded(
                    flex: 2,
                    child: AudioPlayerLine(
                      key: Key('AudioPlayerLine'),
                      currentPosition: current,
                      trackDuration: track,
                      player: player,
                    ),
                  ),
                Expanded(
                  child: AutoSizeText(
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
    if (duration == null) return '';
    final inSeconds = duration.inSeconds;
    final minutes = inSeconds ~/ 60;
    final seconds = inSeconds % 60;
    final s = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutes:$s';
  }
}

class AudioPlayerLine extends StatefulWidget {
  final CityAudioPlayer player;
  final Duration currentPosition;
  final Duration trackDuration;

  const AudioPlayerLine({
    Key key,
    @required this.currentPosition,
    @required this.trackDuration,
    @required this.player,
  }) : super(key: key);

  @override
  _AudioPlayerLineState createState() => _AudioPlayerLineState();
}

class _AudioPlayerLineState extends State<AudioPlayerLine> {
  double moveValue;
  bool isMoving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: SliderTheme(
        data: SliderThemeData(
          trackShape: CustomTrackShape(),
        ),
        child: Slider.adaptive(
          value:
              (moveValue ?? widget.currentPosition.inSeconds.toDouble()) ?? 0,
          min: 0,
          max: (widget.trackDuration < widget.currentPosition
                  ? widget.currentPosition.inSeconds.toDouble()
                  : widget.trackDuration.inSeconds.toDouble()) ??
              0,
          onChanged: (v) {
            setState(() => moveValue = v);
          },
          onChangeEnd: (v) {
            widget.player.seek(Duration(seconds: v.toInt()));
            moveValue = null;
          },
          activeColor: Colors.white,
          inactiveColor: Colors.black,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
