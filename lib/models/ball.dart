import 'package:flutter/material.dart';
import 'package:BBBGame/models/thing.dart';
import 'package:BBBGame/models/values/device.dart';

class Ball extends Thing {
  double get width => Screen.screenWidth / 20;
  double get height => Screen.screenWidth / 20;
  Color get color => Colors.green[400];
  final key = GlobalKey();

  @override
  Container create() {
    return Container(
      key: key,
      width: width.toDouble(),
      height: height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
    );
  }

  /// ساخت توپ
  /// create ball
  Container createBall() {
    return Container(
      key: key,
      width: width.toDouble(),
      height: height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
    );
  }
}
