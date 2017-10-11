import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = const MethodChannel('video_player');

/// A reference to a platform video player playing into a [Texture].
///
/// Instances are created asynchronously with [create].
///
/// The video is shown in a Flutter app by creating a [Texture] widget
/// with [textureId].
class VideoPlayerId {
  final int textureId;

  VideoPlayerId._internal(int textureId) : textureId = textureId;

  static Future<VideoPlayerId> create(String dataSource) async {
    int textureId =
        await _channel.invokeMethod('create', {'dataSource': dataSource});
    return new VideoPlayerId._internal(textureId);
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod('dispose', {'textureId': textureId});
  }

  Future<Null> play() async {
    await _channel.invokeMethod('play', {'textureId': textureId});
  }

  Future<Null> pause() async {
    await _channel.invokeMethod('pause', {'textureId': textureId});
  }

  /// The duration of the current video.
  Future<Duration> get duration async {
    return new Duration(
        milliseconds:
            await _channel.invokeMethod('duration', {'textureId': textureId}));
  }

  Future<Null> seekTo(Duration duration) async {
    await _channel.invokeMethod(
        'seekTo', {'textureId': textureId, 'location': duration.inMilliseconds});
  }
}
