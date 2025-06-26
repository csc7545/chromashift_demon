import 'dart:ui';
import 'package:flame/components.dart';

class WorldBorderComponent extends RectangleComponent {
  WorldBorderComponent({required Vector2 size})
    : super(
        position: Vector2.zero(),
        size: size,
        paint:
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = const Color.fromARGB(255, 255, 20, 98),
      );
}
