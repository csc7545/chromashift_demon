import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/utils/rainbow_color_util.dart'; // 유틸 import

class ScoreHudComponent extends TextComponent {
  int score = 0;
  double time = 0;

  ScoreHudComponent()
    : super(
        text: 'Score: 0',
        position: Vector2(16, 16),
        anchor: Anchor.topLeft,
        priority: 100,
      ) {
    textRenderer = TextPaint(
      style: TextStyle(
        color: RainbowColorUtil.getColor(0),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void increaseScore(int amount) {
    score += amount;
    text = 'Score: $score';
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    final newColor = RainbowColorUtil.getColor(time * 2);
    textRenderer = TextPaint(
      style: TextStyle(
        color: newColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
