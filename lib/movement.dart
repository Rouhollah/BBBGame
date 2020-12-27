import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:BBBGame/models/ball.dart';
import 'package:BBBGame/models/box.dart';
import 'package:BBBGame/models/cursor.dart';
import 'package:BBBGame/models/game_status.dart';
import 'package:BBBGame/services/mathematics_service.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'models/values/device.dart';

class Movement extends StatefulWidget {
  @override
  _MovementState createState() => _MovementState();
}

class _MovementState extends State<Movement>
    with SingleTickerProviderStateMixin {
  Animation<Offset> _animationOffset;
  Tween<Offset> _tweenOffset;
  AnimationController _animationController;
  Random _random = new Random();
  Cursor cursor = new Cursor();
  Ball ball = new Ball();
  String direction;
  int c = 0;
  MathematicsService ms = MathematicsService();

  @override
  void initState() {
    super.initState();
    Offset init = initialBallPosition();
    _animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    _tweenOffset = Tween<Offset>(begin: init, end: init);
    _animationOffset = _tweenOffset.animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    )..addListener(() {
        if (_animationController.status == AnimationStatus.completed) {
          double y = bottomOfBall().dy;
          if (y == Screen.screenHeight / ball.width) {
            _animationController.stop(canceled: false);
          } else
            collision();
        }
      });

    // در نقطه شروع بایستد
    // begin from start point
    _animationController.isDismissed;
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStatus>(context, listen: false);

    return Selector<GameStatus, bool>(
        selector: (ctx, game) => game.firstShoot,
        builder: (context, startGame, child) {
          if (startGame) {
            game.ballDirection = 90;
            routing(game.ballDirection);
          }
          return UnconstrainedBox(
              child: (SlideTransition(
                  position: _animationOffset, child: ball.createBall())));
        });
  }

  routing(int degree) {
    print('routing');
    // پیدا کردن نقطع انتهایی حرکت توپ به سمت مربع یا دیواره ها
    // finding end point for move ball , to boxes or walls
    Offset o = calculateCoordinates(degree)[1];
    // حرکت توپ تا نقطه مشخص شده
    // move to end point
    setNewPosition(o);
  }

  /// پیدا کردن مربع هایی که در مسیر توپ هستند
  /// find boxes in route ball
  List<Box> findBoxesInRouteBall(int degree) {
    print('findBoxesInRouteBall');

    var g = Provider.of<GameStatus>(context, listen: false);
    Offset ballPosition = g.getBallPosition();

    //210
    Offset topBallPos;
    Offset bottomBallPos;
    bottomBallPos = bottomOfBall();
    topBallPos = bottomOfBall();
    List<Box> tempBoxes = new List<Box>();
    // حرکت توپ به سمت پالا
    // move to top
    if (0 < degree && degree < 180 && degree != 90) {
      // مربع های سمت راست توپ
      // توپ است dx آنها بیشتر یا مساوی dx مربع هایی که
      // boxes in right of ball
      // boxes that box.dx >= ball.dx
      if (degree < 90) {
        tempBoxes = g
            .getBoxes()
            .where((element) =>
                element.position.dy / ball.width <= topBallPos.dy &&
                ballPosition.dx <= element.position.dx / ball.width)
            .toList();
      }

      // مربع های سمت چپ توپ
      // توپ است dx آنها کمتر یا مساوی dx + width مربع هایی که
      // boxes in left of ball
      // boxes that box.dx <= ball.dx
      else {
        tempBoxes = g
            .getBoxes()
            .where((element) =>
                element.position.dy / ball.width <= topBallPos.dy &&
                ballPosition.dx >=
                    (element.position.dx + element.width) / ball.width)
            .toList();
      }
    }
    // حرکت توپ به سمت پایین
    // move to down
    else if (180 < degree && degree < 360 && degree != 270) {
      // مربع های سمت جپ توپ
      // توپ است dx آنها کمتر یا مساوی dx + width مربع هایی که
      // boxes in left of ball
      // boxes that box.dx+width <= ball.dx
      if (degree < 270) {
        tempBoxes = g
            .getBoxes()
            .where((element) =>
                element.position.dy / ball.width >= bottomBallPos.dy &&
                ball.position.dx >=
                    (element.position.dx + element.width) / ball.width)
            .toList();
      }
      // مربع های سمت راست توپ
      // توپ است dx آنها بیشتر یا مساوی dx مربع هایی که
      // boxes in right of ball
      // boxes that box.dx >= ball.dx
      else {
        tempBoxes = g
            .getBoxes()
            .where((element) =>
                element.position.dy / ball.width >= bottomBallPos.dy &&
                ball.position.dx >= element.position.dx / ball.width)
            .toList();
      }
    }
    // حرکت مستقیم توپ به بالا
    // direct move to top
    else if (degree == 90) {
      tempBoxes = g
          .getBoxes()
          .where((element) =>
              element.position.dx / ball.width <= topBallPos.dx &&
              topBallPos.dx <=
                  (element.position.dx + element.width) / ball.width &&
              topBallPos.dy >= element.position.dy / ball.width)
          .toList();
    } else {
      tempBoxes = g
          .getBoxes()
          .where((element) =>
              element.position.dx / ball.width <= bottomBallPos.dx &&
              (element.position.dx + element.width) / ball.width >=
                  bottomBallPos.dx &&
              bottomBallPos.dy >= element.position.dy / ball.width)
          .toList();
    }
    return tempBoxes;
  }

  /// محاسبه مختصات حرکت توپ با استفاده از معادله خط
  /// Calculate the coordinates of motion of a ball using the line equation
  List<Offset> calculateCoordinates(int degree) {
    var g = Provider.of<GameStatus>(context, listen: false);
    Offset ballPosition = g.getBallPosition();
    Offset cursorPosition = g.getCursorPosition();
    List<Offset> lstOffset = new List<Offset>();
    num x, y, x2, y2;
    num x1 = ms.transitionPositionToScreenPosition(ballPosition).dx;
    num y1 = ms.transitionPositionToScreenPosition(ballPosition).dy;
    lstOffset.add(Offset(x1, y1));
    double tempX;
    double tempY;
    tempX = degree > 90 && degree < 180
        ? 0.0
        : degree == 90 || degree == 270
            ? x1
            : Screen.screenWidth - ball.width;
    List<Box> boxes = findBoxesInRouteBall(degree);
    // ابتدا انتهای حرکت توپ را مشخص می کنیم .
    // درصورتی که در مسیر توپ یک مربع وجودداشت و برخورد میکرد انتهای حرکت را آپدیت می کنیم
    // First we determine the end of the ball movement.
    // If there is a square in the path of the ball and it collides, we will update the end of the movement
    tempY = initialTempY(degree, y1);

    if (boxes.length > 0) {
      for (Box b in boxes) {
        // با استفاده از معادله خط مشخص می کنیم آیا مربع ها در مسیر توپ هستند یا نه
        // Using the line equation, we determine whether the squares are in the path of the ball or not
        y = degree < 180 ? b.position.dy + b.width : b.position.dy;

        x = ms.equationOfLine(x, y, x1, y1, tempX, tempY);
        x = x < 0
            ? 0
            : x > Screen.screenWidth
                ? Screen.screenWidth
                : x;
        if (b.position.dx <= x && x <= b.position.dx + b.width) {
          tempX = x;
          tempY = y;
          g.boxCollideWithBall = b;
        } else {
          x = null;
          y = degree < 180 ? b.position.dy : b.position.dy + b.width;
          x = ms.equationOfLine(x, y, x1, y1, tempX, tempY);
          x = x < 0
              ? 0
              : x > Screen.screenWidth
                  ? Screen.screenWidth
                  : x;
          if (b.position.dx <= x && x <= b.position.dx + b.width) {
            tempX = x;
            tempY = y;
            g.boxCollideWithBall = b;
          } else {
            y = null;
            x = degree < 90 || degree > 270
                ? b.position.dx
                : b.position.dx + b.width;
            y = ms.equationOfLine(x, y, x1, y1, tempX, tempY);
            y = y < 0.0
                ? 0.0
                : y > Screen.screenHeight - ball.width
                    ? Screen.screenHeight - ball.width
                    : y;
            if (b.position.dy <= y && y <= b.position.dy + b.width) {
              tempX = x;
              tempY = y;
              g.boxCollideWithBall = b;
            } else {
              y = null;
              x = 90 < degree && degree < 270
                  ? b.position.dx + b.width
                  : b.position.dx;
              y = ms.equationOfLine(x, y, x1, y1, tempX, tempY);
              y = y < 0.0
                  ? 0.0
                  : y > Screen.screenHeight - ball.width
                      ? Screen.screenHeight - ball.width
                      : y;
              if (b.position.dy <= y && y <= b.position.dy + b.width) {
                tempX = x;
                tempY = y;
                g.boxCollideWithBall = b;
              }
            }
          }
        }
      }
    }
    // زمان حرکت توپ به پایین صفحه ، باید مقدار وای کرسر را در معادله خط قرار دهیم و ایکس را به دست بیاوریم
    // سپس متد برخورد با کرسر را صدا کنیم
    // When the ball moves to the bottom of the screen, we have to put the value of YCurser in the line equation and get X
    //Then call the cursor collision method
    else if (tempY >= cursorPosition.dy) {
      y = cursorPosition.dy - ball.width;
      x = ms.equationOfLine(x, y, x1, y1, tempX, tempY);
      tempX = x;
      tempY = y;
    } else if (tempY <= 0.0) {
      y = 0.0;
      x = x1;
      tempX = x;
      tempY = y;
      if (y == 0.0 && x == 0) {
        y = y1 + 90;
        g.ballDirection = 300;
      } else if (y == 0 && x == Screen.screenWidth - ball.width) {
        y = y1 + 90;
        g.ballDirection = 240;
      }
    }
    x2 = ms.screenPositionToTransitionPosition(Offset(tempX, tempY)).dx;
    y2 = ms.screenPositionToTransitionPosition(Offset(tempX, tempY)).dy;
    lstOffset.add(Offset(x2, y2));
    return lstOffset;
  }

  /// tempY مقداردهی اولیه برای
  /// iniitalizing for tempY
  double initialTempY(degree, y1) {
    double endPos = Screen.screenHeight - ball.width;
    if (degree == 90)
      return 0.0;
    else if (degree == 30 || degree == 150)
      return y1 - 30 < 0.0 ? 0.0 : y1 - 30;
    else if (degree == 45 || degree == 135)
      return y1 - 60 < 0.0 ? 0.0 : y1 - 60;
    else if (degree == 60 || degree == 120)
      return y1 - 90 < 0.0 ? 0.0 : y1 - 90;
    else if (degree == 270)
      return endPos;
    else if (degree == 210 || degree == 330)
      return y1 + 30 > endPos ? y1 + 30 : endPos;
    else if (degree == 225 || degree == 315)
      return y1 + 60 > endPos ? y1 + 60 : endPos;
    else
      return y1 + 90 > endPos ? y1 + 90 : endPos;
  }

  /// یافتن موقعیت جدید
  /// finding new position
  void setNewPosition(Offset endPosition) {
    print('setNewPosition');
    _tweenOffset.begin = _tweenOffset.end;
    _animationController.reset();
    _tweenOffset.end = endPosition;
    Provider.of<GameStatus>(context, listen: false).setBallPosition(
        Offset(endPosition.dx * ball.width, endPosition.dy * ball.width));
    _animationController.forward();
  }

  /// تعیین زاویه جدید برای حرکت توپ،
  /// حذف مربع در صورت برخورد با آن
  /// Determine the new angle for the ball to move,
  /// Delete the square if it collides with it
  collision() {
    print('collision');

    var g = Provider.of<GameStatus>(context, listen: false);
    Offset leftBallPos = leftOfBall();
    Offset topBallPos = topOfBall();
    Offset rightBallPos = rightOfBall();
    Offset ballPosition = g.getBallPosition();
    int degree = g.ballDirection;
    Box box = g.boxCollideWithBall;

    // Transition Position مختصات مربع بر اساس
    // coordinate of ball based on Transition Position
    Offset boxTransitionPosition;
    double underBoxTransiton;
    if (box != null) {
      underBoxTransiton = (box.position.dy + box.width) / ball.width;
      // حرکت توپ به سمت بالا بوده است
      if (0 < degree && degree < 180) {
        // برخورد با زیر مربع
        // collide with under box
        if (topBallPos.dy >= underBoxTransiton) {
          underBoxCollide(box.position);
        } else {
          // در این زاویه ها توپ به سمت چپ مربع می خورد
          if (degree == 30 || degree == 45 || degree == 60) {
            g.ballDirection = findNewDegree(degree, 'left');
          } else {
            g.ballDirection = findNewDegree(degree, 'right');
          }
        }
        g.removeBox();
        routing(g.ballDirection);
      }
      // حرکت توپ به سمت پایین بوده است
      else if (180 < degree && degree < 360) {
        boxTransitionPosition = ms.screenPositionToTransitionPosition(
            Offset(box.position.dx, box.position.dy));
        if (ballPosition.dy <= boxTransitionPosition.dy) {
          g.ballDirection = findNewDegree(degree, 'up');
        } else {
          // در این زاویه ها توپ به سمت چپ مربع می خورد
          // At these angles the ball hits the left side of the square
          if (degree == 330 || degree == 315 || degree == 300) {
            g.ballDirection = findNewDegree(degree, 'left');
          } else {
            g.ballDirection = findNewDegree(degree, 'right');
          }
          g.removeBox();
          routing(g.ballDirection);
        }
      }
    } else {
      // اگر توپ با دیوار سمت راست برخورد کرد
      // If the ball hits the wall on the right
      if (rightBallPos.dx == Screen.screenWidth / ball.width) {
        g.ballDirection =
            findNewDegree(degree, degree < 180 ? 'left' : 'right');
        routing(g.ballDirection);
      }
      // اگر توپ با دیوار سمت چپ برخورد کرد
      // If the ball hits the wall on the left
      else if (leftBallPos.dx == 0) {
        g.ballDirection =
            findNewDegree(degree, degree < 180 ? 'right' : 'left');
        routing(g.ballDirection);
      }
      // اگر توپ با دیوار بالا برخورد کرد
      // If the ball hits the wall on the top
      else if (topBallPos.dy == 0) {
        g.ballDirection = findNewDegree(degree, 'under');
        routing(g.ballDirection);
      }
      // اگر توپ با کرسر برخورد کرد یا رد شد
      // If the ball hits the cursor or passes
      else
        collideWithCursor(ballPosition);
    }
  }

  /// متد برخورد با زیر مربع و حذف آن
  /// Method of dealing with the sub-square and deleting it
  void underBoxCollide(Offset boxPosition) {
    print('underBoxCollide');

    var g = Provider.of<GameStatus>(context, listen: false);
    Offset topBallPos = topOfBall();
    double boxWidth = Screen.screenWidth / 10;

    // اگر توپ به یک پنجم سمت چپ مربع برخورد کرد
    // If the ball hits the left fifth of the square
    if (topBallPos.dx >= boxPosition.dx / ball.width &&
        topBallPos.dx < (boxPosition.dx + (boxWidth / 5)) / ball.width) {
      g.ballDirection = 210;
    }
    // اگر توپ به یک پنجم سمت راست مربع برخورد کرد
    // If the ball hits the fifth right of the square
    else if (topBallPos.dx >=
            (((boxPosition.dx + boxWidth) - boxWidth / 5) / ball.width) &&
        topBallPos.dx < (boxPosition.dx + boxWidth) / ball.width) {
      g.ballDirection = 330;
    }
    // برخورد با جایی غیر از گوشه های مربع
    // Deal with somewhere other than the corners of the square
    else if (topBallPos.dy == (boxPosition.dy + boxWidth) / ball.width) {
      g.ballDirection = findNewDegree(g.ballDirection, "under");
    }
  }

  findNewDegree(int degree, String point) {
    print('findNewDegree');

    if (point == "under") {
      switch (degree) {
        case 30:
          return 330;
          break;
        case 45:
          return 315;
          break;
        case 60:
          return 300;
          break;
        case 120:
          return 240;
          break;
        case 135:
          return 225;
          break;
        case 150:
          return 210;
          break;
        default:
          return 270;
          break;
      }
    } else if (point == "left") {
      switch (degree) {
        case 30:
          return 150;
          break;
        case 45:
          return 135;
          break;
        case 60:
          return 120;
          break;
        case 300:
          return 240;
          break;
        case 315:
          return 225;
          break;
        case 330:
          return 210;
          break;
      }
    } else if (point == "right") {
      switch (degree) {
        case 120:
          return 60;
          break;
        case 135:
          return 45;
          break;
        case 150:
          return 30;
          break;
        case 210:
          return 330;
          break;
        case 225:
          return 315;
          break;
        case 240:
          return 120;
          break;
      }
    } else {
      switch (degree) {
        case 210:
          return 150;
          break;
        case 225:
          return 135;
          break;
        case 240:
          return 120;
          break;
        case 300:
          return 60;
          break;
        case 315:
          return 45;
          break;
        case 330:
          return 30;
          break;
        default:
          return 90;
          break;
      }
    }
  }

  /// برخورد با کرسر یا پایان بازی
  /// Collision or end of game
  collideWithCursor(Offset start) {
    print('colideWithCursor');

    final g = Provider.of<GameStatus>(context, listen: false);

    Offset cp = g.getCursorPosition();
    var endOfCP = Offset(cp.dx + cursor.width, cp.dy);
    var firstPart = Offset(cp.dx + ball.width, cp.dy);
    var secondPart = Offset(firstPart.dx + ball.width, cp.dy);
    var thirdPart = Offset(secondPart.dx + ball.width, cp.dy);
    var sixth = Offset(cp.dx + cursor.width - ball.width, cp.dy);
    var fifth = Offset(sixth.dx - ball.width, cp.dy);
    var forth = Offset(fifth.dx - ball.width, cp.dy);
    Offset bottomBall = ms.transitionPositionToScreenPosition(bottomOfBall());

    // اگر توپ به کرسر برخورد کرد
    // collision with cursor
    if (bottomBall.dx >= cp.dx && bottomBall.dx <= endOfCP.dx) {
      // برخورد با یک هفتم ابتدایی کرسر- بازگشت 150 درجه
      // Collision with the first seventh of the cursor - 150 degrees return
      if (bottomBall.dx >= cp.dx && bottomBall.dx <= firstPart.dx) {
        g.ballDirection = 150;
      }
      // برخورد با یک هفتم دوم- بازگشت 135 درجه
      else if (bottomBall.dx > firstPart.dx && bottomBall.dx <= secondPart.dx) {
        g.ballDirection = 135;
      }
      // برخورد با یک هفتم سوم- بازگشت 120 درچه
      else if (bottomBall.dx > secondPart.dx && bottomBall.dx <= thirdPart.dx) {
        g.ballDirection = 120;
      }
      // برخورد با یک هفتم بعد از وسط - بازگشت 60 درجه
      else if (bottomBall.dx > forth.dx && bottomBall.dx <= fifth.dx) {
        g.ballDirection = 60;
      }
      // برخورد با یک هفتم دوم بعد از وسط - بازگشت 45 درچه
      else if (bottomBall.dx > fifth.dx && bottomBall.dx <= sixth.dx) {
        g.ballDirection = 45;
      }
      // برخورد با یک هفتم آخر - بازگشت 30 درچه
      else if (bottomBall.dx > sixth.dx &&
          bottomBall.dx <= cp.dx + cursor.width) {
        g.ballDirection = 30;
      }
      // برخورد با وسط - بازگشت 90 درچه
      // Collision with the middle - 90 degree return
      else {
        g.ballDirection = findNewDegree(g.ballDirection, 'up');
      }
      routing(g.ballDirection);
    } else {
      // عبور از کرسر - باخت
      // Crossing the cursor - loss
      gameOver(start);
    }
  }

  /// مقدار دهی اولیه موقعیت توپ
  /// initial ball position
  Offset initialBallPosition() {
    var bw = ball.width;
    // بر اساس اندازه صفحه تقسیم بر اندازه آبجکتی است که قرار است حرکت کند SlideTransition چون مختصات
    // این محاسبات جای دقیق توپ روی کرسر را درابتدا پیدا می کند
    // Based on the page size is divided by the size of the object to be moved SlideTransition as coordinates
    // These calculations first find the exact location of the ball on the cursor
    double dx = (cursor.position.dx + cursor.width / 2 - bw / 2) / bw;
    double dy = ((cursor.position.dy - ball.height) / bw);
    // دوباره بر عرض توپ تقسیم می شوند provider در عرض توپ ضرب میشوند اما در dy و dx اینجا
    // Here dx and dy are multiplied by the width of the ball and divided by the width of the ball in the provider
    Offset offset = Offset(dx * bw, dy * bw);
    Provider.of<GameStatus>(context, listen: false).setBallPosition(offset);
    return Offset(dx, dy);
  }

  int generateRandomNumber({min = 1, max = 20}) {
    int num = min + _random.nextInt(max - min);
    return num;
  }

  gameOver(Offset start) {
    var g = Provider.of<GameStatus>(context, listen: false);
    g.firstShoot = false;
    print('game over');
    Offset end = Offset(g.getBallPosition().dx,
        (Screen.screenHeight - ball.width) / ball.width);
    if (g.ballDirection != 270) {
      double y = Screen.screenHeight - ball.width;
      double x;
      x = ms.equationOfLine(
          x,
          y,
          g.getBallPosition().dx * ball.width,
          g.getBallPosition().dy * ball.width,
          start.dx * ball.width,
          start.dy * ball.width);
      end = ms.screenPositionToTransitionPosition(Offset(x, y));
    }
    setNewPosition(end);
  }

  /// تبدیل درجه به رادیانس
  num degreeToRadians(num degree) {
    return (degree * math.pi) / 180;
  }

  /// تبدیل رادیانس به درجه
  num radianseToDegree(num radianse) {
    return (radianse * 180) / math.pi;
  }

  Offset leftOfBall() {
    var g = Provider.of<GameStatus>(context, listen: false);
    var ballPos = g.getBallPosition();
    var left = Offset(ballPos.dx, ballPos.dy + ((ball.width / 2) / ball.width));
    return left;
  }

  Offset rightOfBall() {
    var g = Provider.of<GameStatus>(context, listen: false);
    var ballPos = g.getBallPosition();
    var right =
        Offset(ballPos.dx + 1, ballPos.dy + ((ball.width / 2) / ball.width));
    return right;
  }

  /// نقطه بالایی توپ
  Offset topOfBall() {
    var g = Provider.of<GameStatus>(context, listen: false);
    var ballPos = g.getBallPosition();
    var top = Offset(ballPos.dx + ((ball.width / 2) / ball.width), ballPos.dy);
    return top;
  }

  Offset bottomOfBall() {
    var g = Provider.of<GameStatus>(context, listen: false);
    var ballPos = g.getBallPosition();
    var bottom = Offset(ballPos.dx + ((ball.width / 2) / ball.width),
        (ballPos.dy * ball.width + ball.width) / ball.width);
    return bottom;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
