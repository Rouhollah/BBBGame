import 'package:BBBGame/models/box.dart';
import 'package:flutter/material.dart';
import 'package:BBBGame/models/ball.dart';
import 'package:BBBGame/models/level.dart';

class GameStatus extends ChangeNotifier {
  bool started = false;
  bool firstShoot = false;
  Offset _ballPostion;
  Offset _cursorPosition;
  List keisOfBoxes = new List();
  List<Box> boxes = new List<Box>();
  List<Box> _boxes = new List<Box>();
  List<Level> levelsList = new List<Level>();
  dynamic jsonLevels;

  int ballDirection;
  Box boxCollideWithBall;

  void gameStart(firstShoot) {
    this.firstShoot = firstShoot;
    this.started = firstShoot;
    notifyListeners();
  }

  void setBoxes(Box box) {
    _boxes.add(box);
  }

  List<Box> getBoxes() => _boxes;

  removeBox() {
    _boxes.removeWhere((element) => element.key == boxCollideWithBall.key);
    boxCollideWithBall = null;
    notifyListeners();
  }

  /// transition position موقعیت توپ بر اساس
  /// ball position based on transition position
  void setBallPosition(Offset position) {
    _ballPostion =
        Offset(position.dx / Ball().width, position.dy / Ball().width);
  }

  /// Height Transition دریافت موقعیت توپ براساس
  /// get ball position based on transition position
  getBallPosition() => _ballPostion;

  /// ست کردن موقعیت کرسر در هر لحظه
  /// set cursor positon any time
  void setCursorPosition(dx, dy) {
    this._cursorPosition = Offset(dx, dy);
  }

  /// دریافت موقعیت کرسر در هر لحظه
  /// get cursor position any time
  Offset getCursorPosition() {
    return _cursorPosition;
  }
}
