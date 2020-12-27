import 'package:flutter/material.dart';
import 'package:BBBGame/models/ball.dart';

class MathematicsService {
  /// مجهولاتی که میخواهیم به دست بیاوریم (x,y) مختصات مربع و (x2,y2) مختصات توپ و (x1,y1)
  num equationOfLine(num x, num y, num x1, num y1, num x2, num y2) {
    if (y == null) {
      y = ((y1 - y2) / (x1 - x2)) * (x - x1) + y1;
      return y;
    } else {
      x = (((y - y1) * (x1 - x2)) / (y1 - y2)) + x1;
      return x;
    }
  }

  /// تبدیل مختصات توپ به مختصات صفحه
  /// convert coordinate of ball to non transition position
  Offset transitionPositionToScreenPosition(Offset o) {
    return Offset(o.dx * Ball().width, o.dy * Ball().width);
  }

  /// تبدیل مختصات صفحه به مختصات  توپ
  /// convet ball coordinate to transition position
  Offset screenPositionToTransitionPosition(Offset o) {
    return Offset(o.dx / Ball().width, o.dy / Ball().width);
  }
}
