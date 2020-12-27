import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:BBBGame/models/cursor.dart';
import 'package:BBBGame/models/game_status.dart';
import 'package:BBBGame/models/values/device.dart';
import 'package:provider/provider.dart';

class TrackFinger extends StatefulWidget {
  @override
  _TrackFingerState createState() => _TrackFingerState();
}

class _TrackFingerState extends State<TrackFinger> {
  bool firstShoot = true;
  Cursor cursor = new Cursor();
  double posy;
  double posx;
  @override
  void initState() {
    super.initState();

    //initial positon of cursor
    posy = Screen.screenHeight - (5 * cursor.height);
    posx = Screen.screenWidth / 2 - cursor.width / 2;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) => onTapDown(context, details),
      child: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        Container(
          color: Colors.yellow[200],
        ),
        AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: posy,
            left: posx,
            child: cursor.createCursor()),
      ]),
    );
  }

  /// محاسبه حرکت کرسر
  /// calculate cursor move
  void onTapDown(BuildContext context, TapDownDetails details) {
    // اگر اولین لمس کاربر بود
    // If it was the user's first touch
    if (firstShoot) {
      // اطلاع بده بازی شروع شد provider به
      // Notify Provider The game has started
      Provider.of<GameStatus>(context, listen: false).gameStart(firstShoot);
      firstShoot = false;
    }
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      double rEdge = calculateSpaceToRightEdges();
      posx = localOffset.dx >= rEdge ? rEdge : localOffset.dx;
      Provider.of<GameStatus>(context, listen: false)
          .setCursorPosition(posx, posy);
    });
  }

  /// محاسبه فاصله ای که کرسر نباید بیشتر از آن به سمت راست برود. چون از صفحه خارح می شود
  /// Calculate the distance that the cursor should not go more than to the right. Because it is removed from the page
  calculateSpaceToRightEdges() {
    double rightEdge =
        MediaQuery.of(context).size.width - cursor.width.toDouble();
    return rightEdge;
  }

  nextLevel() {
    print('next level');
  }

  playAgain() {
    print('play again');
  }
}
