import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel =
    const MethodChannel('video_player');

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
  }

  @override
  Widget build(BuildContext context) {
    if (imageId == null) {
      return const Text('Uninitialized');
    }
    return new TextureHolder(imageId);
  }
}

class TextureHolder extends StatefulWidget {
  int imageId;

  TextureHolder(this.imageId);

  createState() => new TextureHolderState(imageId);
}

class TextureHolderState extends State<TextureHolder>
    with TickerProviderStateMixin {
  int imageId;

  TextureHolderState(this.imageId);

  @override
  void initState() {
    super.initState();
    controller =
    new AnimationController(vsync: this, duration: new Duration(days: 2));
    controller.animateTo(1.0);
  }

  AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: 100.0,
      height: 100.0,
      child: new AnimatedExternalImage(controller, imageId: imageId),
    );
  }
}
