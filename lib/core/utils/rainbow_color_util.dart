import 'dart:math';
import 'package:flutter/material.dart';

class RainbowColorUtil {
  static Color getColor(double time) {
    final r = (sin(time) * 127 + 128).round();
    final g = (sin(time + 2 * pi / 3) * 127 + 128).round();
    final b = (sin(time + 4 * pi / 3) * 127 + 128).round();
    return Color.fromARGB(255, r, g, b);
  }
}
