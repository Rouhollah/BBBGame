import 'package:flutter/material.dart';
import 'package:BBBGame/boxes.dart';
import 'package:BBBGame/movement.dart';
import 'package:BBBGame/trackFinger.dart';
import 'package:provider/provider.dart';

import 'models/game_status.dart';
import 'models/level.dart';

class Play extends StatefulWidget {
  final Level level;
  Play(this.level);
  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  @override
  Widget build(BuildContext context) {
    print(widget.level.level);
    return ChangeNotifierProvider<GameStatus>(
        create: (context) => GameStatus(),
        child:
            Stack(children: [TrackFinger(), Boxes(widget.level), Movement()]));
  }
}
