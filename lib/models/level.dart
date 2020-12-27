import 'package:BBBGame/models/type_box.dart';

class Level {
  int level;
  bool passed;
  List<TypeBox> boxes;
  Level({this.level, this.passed, this.boxes});

  factory Level.fromJson(Map<String, dynamic> json) {
    var levelBoxes = json['boxes'] as List;
    var list =
        levelBoxes.map<TypeBox>((json) => TypeBox.fromJson(json)).toList();
    return Level(level: json['level'], passed: json['passed'], boxes: list);
  }
}
