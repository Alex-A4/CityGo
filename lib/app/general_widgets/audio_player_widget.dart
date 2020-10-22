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
          Duration current;
          Duration track;

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
            current = status.currentPosition;
            track = status.trackDuration;
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
  double movePercent;
  bool isMoving = false;

  @override
  Widget build(BuildContext context) {
    final percent =
        widget.currentPosition.inSeconds / widget.trackDuration.inSeconds;

    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: height / 2,
                left: 0,
                height: height,
                width: width,
                child: GestureDetector(
                  onPanStart: (d) {
                    movePercent = d.localPosition.dx / width;
                    setState(() => isMoving = true);
                  },
                  onPanUpdate: (d) {
                    movePercent = d.localPosition.dx / width;
                    setState(() {});
                  },
                  onPanEnd: (d) {
                    final seconds =
                        widget.trackDuration.inSeconds * movePercent;
                    widget.player.seek(Duration(seconds: seconds.toInt()));
                    movePercent = null;
                    setState(() => isMoving = false);
                  },
                  child: CustomPaint(
                    painter:
                        LinePainter(percent: isMoving ? movePercent : percent),
                  ),
                ),
              ),
              Positioned(
                top: height / 2,
                left: isMoving ? width * movePercent : width * percent,
                child: CustomPaint(painter: DotPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Пэинтер для отображения линии прогресса
class LinePainter extends CustomPainter {
  final double percent;

  LinePainter({@required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final needLinePainter = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;
    final completeLinePainter = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    canvas.drawLine(
        Offset(0, 0), Offset(size.width * percent, 0), completeLinePainter);
    canvas.drawLine(Offset(size.width * percent, 0), Offset(size.width, 0),
        needLinePainter);
  }

  @override
  bool shouldRepaint(covariant LinePainter old) => percent != old.percent;
}

/// Пэинтер для рисования точки у полосы плеера
class DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.transparent,
    );
    canvas.drawCircle(Offset(0, 0), 8, painter);
  }

  @override
  bool shouldRepaint(covariant DotPainter old) => false;
}
