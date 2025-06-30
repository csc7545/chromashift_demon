import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';

class HealthBarComponent extends PositionComponent
    with HasGameReference<KillTheBloomGame> {
  final int maxHealth;
  int currentHealth;
  final Vector2 heartSize;
  final int heartsPerRow;

  late Sprite bgSprite;
  late Sprite borderSprite;
  late Sprite heartSprite;

  HealthBarComponent({
    required this.maxHealth,
    required this.currentHealth,
    required this.heartSize,
    required this.heartsPerRow,
    super.position,
  }) {
    size = Vector2(
      heartSize.x * heartsPerRow,
      heartSize.y * ((maxHealth / heartsPerRow).ceil()),
    );
  }

  @override
  Future<void> onLoad() async {
    final bgImage = await game.images.load('heart/background.png');
    final borderImage = await game.images.load('heart/border.png');
    final heartImage = await game.images.load('heart/heart.png');

    bgSprite = Sprite(bgImage);
    borderSprite = Sprite(borderImage);
    heartSprite = Sprite(heartImage);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (int i = 0; i < maxHealth; i++) {
      final isFilled = i < currentHealth;
      final row = i ~/ heartsPerRow;
      final col = i % heartsPerRow;
      final offset = Vector2(col * heartSize.x, row * heartSize.y);

      // 배경
      bgSprite.render(canvas, position: offset, size: heartSize);

      // 채워진 하트만 표시
      if (isFilled) {
        heartSprite.render(canvas, position: offset, size: heartSize);
      }

      // 테두리 (항상)
      borderSprite.render(canvas, position: offset, size: heartSize);
    }
  }

  void updateHealth(int newHealth) {
    currentHealth = newHealth.clamp(0, maxHealth);
  }
}
