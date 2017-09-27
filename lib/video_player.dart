import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = const MethodChannel('video_player');

/// A reference to a platform video player playing into an [ExternalImage].
///
/// Instances are created asynchronously with [create].
///
/// The video is shown in a flutter app by creating an [ExternalImage] widget
/// with [imageId].
class VideoPlayerId {
  final int imageId;

  VideoPlayerId._internal(int imageId) : imageId = imageId;

  static Future<VideoPlayerId> create(String dataSource) async {
    int imageId =
        await _channel.invokeMethod('create', {'dataSource': dataSource});
    return new VideoPlayerId._internal(imageId);
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod('dispose', {'imageId': imageId});
  }

  Future<Null> play() async {
    await _channel.invokeMethod('play', {'imageId': imageId});
  }

  Future<Null> pause() async {
    await _channel.invokeMethod('pause', {'imageId': imageId});
  }

  /// The duration of the current video.
  Future<Duration> get duration async {
    return new Duration(
        milliseconds:
            await _channel.invokeMethod('duration', {'imageId': imageId}));
  }

  Future<Null> seekTo(Duration duration) async {
    await _channel.invokeMethod(
        'seekTo', {'imageId': imageId, 'location': duration.inMilliseconds});
  }
}
