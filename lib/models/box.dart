import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:BBBGame/models/thing.dart';
import 'package:BBBGame/models/values/device.dart';

class Box extends Thing {
  double get width => Screen.screenWidth / 10;
  double get height => Screen.screenWidth / 10;
  final key = new GlobalKey();

  Box({String type = 'natural', double x, double y}) {
    position = Offset(x, y);
    switch (type) {
      case 'fire':
        color = Colors.yellow;
        break;
      case 'stone':
        color = Colors.blueGrey;
        break;
      case 'bomb':
        color = Colors.black;
        break;
      case 'earthquake':
        color = Colors.red;
        break;
      default:
        color = Colors.green;
    }
    create();
  }

  @override
  Column create() {
    return Column(
      key: key,
      children: [Container(width: width, height: height, color: color)],
    );
  }
}
