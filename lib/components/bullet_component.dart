import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:chromashift_demon/components/enemy_component.dart';
import 'package:chromashift_demon/element_type.dart';
import 'package:chromashift_demon/chromashift_demon_game.dart';

class BulletComponent extends SpriteAnimationComponent
    with HasGameReference<ChromaShiftDemonGame>, CollisionCallbacks {
  final ElementType type;
  final Vector2 direction;
  final double speed = 300;

  BulletComponent({
    required this.type,
    required Vector2 position,
    required this.direction,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final (filename, frameSize) = switch (type) {
      ElementType.red => ('ball/fireball.png', Vector2(68, 9)),
      ElementType.green => ('ball/poisonball.png', Vector2(65, 9)),
      ElementType.blue => ('ball/iceball.png', Vector2(84, 9)),
    };

    final image = await game.images.load(filename);
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: frameSize,
      ),
    );

    size = Vector2(68, 9);
    add(RectangleHitbox());
    flipHorizontally();
  }

  @override
  void update(double dt) {
    position += direction.normalized() * speed * dt;
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent && !other.isDead) {
      other.takeDamage(type);
      removeFromParent();
    }
  }
}
