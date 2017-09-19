import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

Widget buildCard(String title) {
  return new Card(
    child: new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new ListTile(
          leading: const Icon(Icons.airline_seat_flat_angled),
          title: new Text(title),
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
  print("Hej");
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

//        new ListView(
//          children: [
//            buildCard("Airline a"),
//            buildCard("Airline b"),
//            buildCard("Airline c"),
//            buildCard("Airline d"),
//            buildCard("Airline e"),
//            buildCard("Airline f"),
//            buildCard("Airline g"),
//            new Card(
//                child: new Column(children: [
//                  new Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: [
//                      new Stack(
//                          alignment: FractionalOffset.bottomRight,
//                          children: <Widget>[
//                            new SizedBox(
//                              width: 280.0,
//                              height: 210.0,
//                              child: new VideoPlayer(),
//                            ),
//                            new Image.asset('assets/flutter-mark-square-64.png'),
//                          ]),
//                      new Text(
//                        "video video!",
//                      ),
//                    ],
//                  ),
//                  new ButtonTheme.bar(
//                    child: new ButtonBar(
//                      children: <Widget>[
//                        new FlatButton(
//                          child: const Text('BUY TICKETS'),
//                          onPressed: () {/* ... */},
//                        ),
//                        new FlatButton(
//                          child: const Text('LISTEN'),
//                          onPressed: () {/* ... */},
//                        ),
//                      ],
//                    ),
//                  ),
//                ])),
//            buildCard("Airline h"),
//            buildCard("Airline i"),
//            buildCard("Airline j"),
//            buildCard("Airline k"),
//            buildCard("Airline l"),
//          ],
//        ),
//      )));
}
