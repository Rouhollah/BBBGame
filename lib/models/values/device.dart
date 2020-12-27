import 'dart:ui';
import 'package:BBBGame/models/ball.dart';

Ball ball = new Ball();

class Screen {
  ///عرض صفحه
  /// screen width
  static double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;

  /// ارتفاع صفحه
  /// screen height
  static double screenHeight =
      window.physicalSize.height / window.devicePixelRatio;

  ///حذاکثر اندازه حرکت توب در عرض صفحه
  ///maximum of ball movement in width
  static double maxWidthForBallTransition = screenWidth / ball.width;

  ///حداکثر انازه حرکت توپ در ارتفاع صفحه
  //////maximum of ball movement in height
  static double maxHeightForBallTransition = screenWidth / ball.width;
}
