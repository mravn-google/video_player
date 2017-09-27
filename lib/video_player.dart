import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = const MethodChannel('video_player');

class VideoPlayerId {
  final int _imageId;

  VideoPlayerId._internal(int imageId) : _imageId = imageId;

  static Future<VideoPlayerId> create(String dataSource) async {
    int imageId =
        await _channel.invokeMethod('create', {'dataSource': dataSource});
    return new VideoPlayerId._internal(imageId);
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod('dispose', {'imageId': _imageId});
  }

  Future<Null> play() async {
    await _channel.invokeMethod('play', {'imageId': _imageId});
  }

  Future<Null> pause() async {
    await _channel.invokeMethod('pause', {'imageId': _imageId});
  }

  /// The duration of the current video.
  Future<Duration> get duration async {
    return new Duration(
        milliseconds:
            await _channel.invokeMethod('duration', {'imageId': _imageId}));
  }

  Future<Null> seekTo(Duration duration) async {
    await _channel.invokeMethod(
        'seekTo', {'imageId': _imageId, 'location': duration.inMilliseconds});
  }
}

class VideoPlayer extends StatefulWidget {
  final VideoPlayerId videoPlayerRef;

  VideoPlayer(this.videoPlayerRef);

  @override
  State createState() {
    return new _VideoPlayerState(videoPlayerRef);
  }
}

class _VideoPlayerState extends State<StatefulWidget> {
  final VideoPlayerId videoPlayerRef;
  bool isPlaying = true;

  _VideoPlayerState(this.videoPlayerRef);

  @override
  void initState() {
    super.initState();
    if (isPlaying) videoPlayerRef.play();
  }

  @override
  void deactivate() {
    if (isPlaying) videoPlayerRef.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new ExternalImage(imageId: videoPlayerRef._imageId),
      onTap: () {
        isPlaying = !isPlaying;
        setState(() {});
        if (isPlaying) {
          videoPlayerRef.play();
        } else {
          videoPlayerRef.pause();
        }
      },
    );
  }
}
