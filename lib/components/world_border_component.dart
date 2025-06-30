import 'dart:ui';
import 'package:flame/components.dart';
import 'package:kill_the_bloom/utils/rainbow_color_util.dart';

class WorldBorderComponent extends RectangleComponent {
  double time = 0;

  WorldBorderComponent({required Vector2 size})
    : super(
        position: Vector2.zero(),
        size: size,
        paint:
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
      );

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    paint.color = RainbowColorUtil.getColor(time * 2); // 속도 조절 가능
  }
}
