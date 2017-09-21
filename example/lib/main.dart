import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    new MaterialApp(
      home: new Scaffold(
        body: new Column(children: [
          new SizedBox(
              width: 280.0,
              height: 210.0,
              child: new VideoPlayer(
                  'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_5mb.mp4')),
          new SizedBox(
              width: 280.0,
              height: 210.0,
              child: new VideoPlayer(
                  'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4')),
        ]),
      ),
    ),
  );
}
