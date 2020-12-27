import 'package:flutter/material.dart';

abstract class Thing {
  Offset position;
  double width;
  double height;
  GlobalKey key;
  Color color;
  String type;

  dynamic create();
}
