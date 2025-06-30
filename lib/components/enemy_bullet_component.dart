import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:kill_the_bloom/components/player_component.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';

class EnemyBulletComponent extends SpriteComponent
    with HasGameReference<KillTheBloomGame>, CollisionCallbacks {
  final double speed = 250;

  EnemyBulletComponent({required Vector2 startPosition}) {
    size = Vector2(96, 64);
    anchor = Anchor.center;
    position = startPosition;
  }

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('demon/demon_ball.png');
    sprite = Sprite(image, srcSize: Vector2(48, 32));
    flipHorizontally();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.player.isMounted) return;

    final playerPos = game.player.position.clone();
    final direction = (playerPos - position).normalized();

    // 실시간 유도
    position += direction * speed * dt;

    // 방향에 따른 회전
    angle = atan2(direction.y, direction.x);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && !other.isDead) {
      other.takeDamage();
      removeFromParent();
    }
  }
}
