import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = const MethodChannel('video_player');

class VideoPlayer extends StatefulWidget {
  final String dataSource;

  VideoPlayer(this.dataSource);

  @override
  State createState() {
    return new _VideoPlayerState(dataSource);
  }
}

class _VideoPlayerState extends State<StatefulWidget> {
  int imageId;
  Future<Null> gotImageId;
  final String dataSource;

  _VideoPlayerState(this.dataSource);

  @override
  void initState() {
    super.initState();
    gotImageId = _channel.invokeMethod('createVideoPlayer', {'dataSource': dataSource}).then((int imageId) {
      setState(() {
        print("Got imageId: $imageId");
        this.imageId = imageId;
      });
    });
  }


  @override
  void dispose() {
    gotImageId.then((_) {
      _channel.invokeMethod('disposeVideoPlayer', {'imageId': imageId});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (imageId == null) {
      return const Text('Uninitialized');
    }
    return new ExternalImage(imageId: imageId);
  }
}
