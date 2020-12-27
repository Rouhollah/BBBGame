import 'dart:math';

import 'package:BBBGame/models/level.dart';
import 'package:flutter/material.dart';
import 'package:BBBGame/models/box.dart';
import 'package:BBBGame/models/game_status.dart';
import 'package:BBBGame/models/type_box.dart';
import 'package:provider/provider.dart';

class Boxes extends StatefulWidget {
  final Level level;
  Boxes(this.level);

  @override
  _BoxesState createState() => _BoxesState();
}

class _BoxesState extends State<Boxes> {
  Random random = new Random();
  List<Widget> lst = new List();
  List<TypeBox> boxOfLevel = new List<TypeBox>();

  @override
  void initState() {
    super.initState();
    var g = Provider.of<GameStatus>(context, listen: false);
    Level level = g.levelsList.firstWhere(
        (element) => element.level == widget.level.level,
        orElse: () => null);

    // اضافه نشده بود ، اضافه کن provider قبلا به level اگر
    // add level to provider if it doen't
    if (level == null) {
      g.levelsList.add(widget.level);
      for (var level in g.levelsList) {
        for (var item in level.boxes) {
          Box b = new Box(type: item.type, x: item.x, y: item.y);
          g.setBoxes(b);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return constantBox();
  }

  Widget constantBox() {
    final game = Provider.of<GameStatus>(context);
    return Selector<GameStatus, List<Box>>(
      selector: (buildContext, geme) => game.getBoxes(),
      builder: (context, boxes, child) {
        lst = [];
        Positioned positioned;
        for (var item in boxes) {
          positioned = new Positioned(
              top: item.position.dy,
              left: item.position.dx,
              child: item.create());
          lst.add(positioned);
        }
        return Container(
            child: Stack(children: [
          ...lst,
        ]));
      },
    );
  }

  /// ایجاد عدد تصادفی در یک رنج ، پیشفرض بین یک تا 10 است
  /// create random number in specific range
  int generateRandomNumber({min = 1, max = 10}) {
    int num = min + random.nextInt(max - min);
    return num;
  }
}
