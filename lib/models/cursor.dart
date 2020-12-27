import 'package:flutter/material.dart';
import 'package:BBBGame/models/values/device.dart';

class Cursor {
  ///در کانستاراکتور موقعیت اولیه محاسبه می شود
  /// initial position in cunstructor
  Cursor() {
    // موقیعت اولیه کرسر
    // initial position
    position = new Offset(
        Screen.screenWidth / 2 - width / 2, Screen.screenHeight - (5 * height));
  }

  double width = Screen.screenWidth / 5;
  double height = Screen.screenWidth / 30;
  Color color = Colors.blue[300];
  Offset position;
  double leftPosition;
  double topPosition;
  GlobalKey key = new GlobalKey();

  /// ساخت کرسر با اندازه اولیه
  /// create cursor with initial value
  Container createCursor() {
    return Container(
      key: key,
      width: width,
      height: height,
      color: color,
    );
  }
}
