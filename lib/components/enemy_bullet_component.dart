import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:chromashift_demon/components/player_component.dart';
import 'package:chromashift_demon/chromashift_demon_game.dart';

class EnemyBulletComponent extends SpriteComponent
    with HasGameReference<ChromaShiftDemonGame>, CollisionCallbacks {
  final double speed = 100;

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
    if (!game.player!.isMounted) return;

    final playerPos = game.player!.position.clone();
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
