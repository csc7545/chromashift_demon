import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:kill_the_bloom/components/player_component.dart';
import 'package:kill_the_bloom/element_type.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';

class ElementChangerComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<KillTheBloomGame> {
  final ElementType type;
  final void Function()? onCollected;

  ElementChangerComponent({
    required this.type,
    required Vector2 position,
    this.onCollected,
  }) : super(position: position, size: Vector2(15, 30), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final (filename, frameCount, frameSize) = switch (type) {
      ElementType.red => ('ball/small_fireball.png', 10, Vector2(10, 26)),
      ElementType.green => ('ball/small_poisonball.png', 10, Vector2(9, 25)),
      ElementType.blue => ('ball/small_iceball.png', 10, Vector2(9, 24)),
    };

    final image = await game.images.load(filename);
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: 0.08,
        textureSize: frameSize,
      ),
    );

    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerComponent) {
      other.changeElement(type);
      onCollected?.call();
      Future.microtask(() => removeFromParent());
    }
  }
}
