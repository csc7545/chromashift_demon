import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreHudComponent extends TextComponent {
  int score = 0;

  ScoreHudComponent()
    : super(
        text: 'Score: 0',
        position: Vector2(16, 16),
        anchor: Anchor.topLeft,
        priority: 100, // 항상 위에 렌더링
      ) {
    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void increaseScore(int amount) {
    score += amount;
    text = 'Score: $score';
  }
}
