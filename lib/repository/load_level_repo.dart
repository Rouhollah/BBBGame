import 'package:flutter/services.dart';

class LoadLevelRepository {
  /// خواندن فایل جیسون
  /// load json file
  Future<String> loadFromAsset() async {
    return await rootBundle.loadString("assets/levels.json");
  }
}
