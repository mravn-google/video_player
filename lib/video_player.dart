import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = const MethodChannel('video_player');

/// A reference to a platform video player playing into a [PlatformSurface].
///
/// Instances are created asynchronously with [create].
///
/// The video is shown in a flutter app by creating a [PlatformSurface] widget
/// with [surfaceId].
class VideoPlayerId {
  final int surfaceId;

  VideoPlayerId._internal(int surfaceId) : surfaceId = surfaceId;

  static Future<VideoPlayerId> create(String dataSource) async {
    int surfaceId =
        await _channel.invokeMethod('create', {'dataSource': dataSource});
    return new VideoPlayerId._internal(surfaceId);
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod('dispose', {'surfaceId': surfaceId});
  }

  Future<Null> play() async {
    await _channel.invokeMethod('play', {'surfaceId': surfaceId});
  }

  Future<Null> pause() async {
    await _channel.invokeMethod('pause', {'surfaceId': surfaceId});
  }

  /// The duration of the current video.
  Future<Duration> get duration async {
    return new Duration(
        milliseconds:
            await _channel.invokeMethod('duration', {'surfaceId': surfaceId}));
  }

  Future<Null> seekTo(Duration duration) async {
    await _channel.invokeMethod(
        'seekTo', {'surfaceId': surfaceId, 'location': duration.inMilliseconds});
  }
}
