import 'dart:math' show sin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

MethodChannel textureChannel = new MethodChannel("flutter/textures");

class AnimatedVideo extends StatefulWidget {
  AnimatedVideo(this.video);

  final VideoPlayer video;

  createState() => new AnimatedVideoState(video);
}

class AnimatedVideoState extends State<AnimatedVideo> with TickerProviderStateMixin {
  AnimatedVideoState(this.video);

  @override
  void initState() {
    super.initState();
    controller =
        new AnimationController(vsync: this, duration: new Duration(days: 2));
    controller.animateTo(1.0);
  }

  VideoPlayer video;
  AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double rad = 0.0;
    return new AnimatedBuilder(
        animation: controller,
        builder: (b, c) {
          rad += 0.02;
          return new Transform.rotate(angle: rad, child: new SizedBox(
            width: 200.0 + 80.0 * sin(rad),
            height: 180.0 - 50.0 * sin(rad),
            child: video,
          ));
        });
  }
}

Widget buildCard(String title) {
  return new Card(
    child: new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new ListTile(
          leading: const Icon(Icons.airline_seat_flat_angled),
          title: new Text(title),
          //      subtitle: const Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
        ),
        new ButtonTheme.bar(
          // make buttons use the appropriate styles for cards
          child: new ButtonBar(
            children: <Widget>[
              new FlatButton(
                child: const Text('BUY TICKETS'),
                onPressed: () {/* ... */},
              ),
              new FlatButton(
                child: const Text('LISTEN'),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void main() {
  final VideoPlayer video = new VideoPlayer('http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4');
  runApp(new MaterialApp(
      home: new Scaffold(
    body: new ListView(
      children: [
        buildCard("Airline a"),
        buildCard("Airline b"),
        buildCard("Airline c"),
        buildCard("Airline d"),
        buildCard("Airline e"),
        buildCard("Airline f"),
        buildCard("Airline g"),
        new Card(
            child: new Column(children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              new Stack(
                  alignment: FractionalOffset.bottomRight + new FractionalOffset(-0.2, -0.3),
                  children: <Widget>[
                    new SizedBox(child: new Center(child: new AnimatedVideo(video)), width: 300.0, height: 300.0),
                    new Image.asset('assets/flutter-mark-square-64.png'),
                  ]),
              new Text(
                "video video!",
              ),
            ],
          ),
          new ButtonTheme.bar(
            // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {/* ... */},
                ),
                new FlatButton(
                  child: const Text('LISTEN'),
                  onPressed: () {/* ... */},
                ),
              ],
            ),
          ),
        ])),
        buildCard("Airline h"),
        buildCard("Airline i"),
        buildCard("Airline j"),
        buildCard("Airline k"),
        buildCard("Airline l"),
        buildCard("Airline m"),
        buildCard("Airline n"),
        buildCard("Airline o"),
        buildCard("Airline p"),
        buildCard("Airline q"),
        buildCard("Airline r"),
        buildCard("Airline t"),
        buildCard("Airline u"),
        buildCard("Airline v"),
        buildCard("Airline w"),
      ],
    ),
  )));
}
