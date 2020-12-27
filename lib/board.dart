import 'dart:math';

import 'package:BBBGame/play.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BBBGame/models/cursor.dart';
import 'package:BBBGame/models/level.dart';
import 'package:BBBGame/services/load_level_service.dart';

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Random random = new Random();
  Cursor cursor = new Cursor();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LoadLevelService levelService = new LoadLevelService();
    Future<dynamic> levelList = levelService.parseJson().then((value) {
      return value;
    });
    return FutureBuilder(
        future: levelList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Future hasn't finished yet, return a placeholder
            return Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else {
            var rest = snapshot.data['levels'] as List;
            var list = rest.map<Level>((json) => Level.fromJson(json)).toList();

            return Container(
                color: Colors.green[100],
                child: GridView.count(
                  crossAxisCount: 4,
                  scrollDirection: Axis.vertical,
                  children: List.generate(list.length, (index) {
                    return RaisedButton(
                        onPressed: () {
                          Level level = list
                              .where((element) => element.level == index + 1)
                              .first;
                          loadLevel(level);
                        },
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(fontSize: 30),
                        ),
                        shape: StadiumBorder());
                  }),
                ));
          }
        });
  }

  loadLevel(level) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Play(level)));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
