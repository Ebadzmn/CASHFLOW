import 'package:flutter/foundation.dart';

class Helpers {
  static void printLog(String message) {
    if (kDebugMode) {
      print("LOG: $message");
    }
  }
}
