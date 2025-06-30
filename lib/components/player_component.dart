import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:kill_the_bloom/components/bullet_component.dart';
import 'package:kill_the_bloom/components/heart_bar_component.dart';
import 'package:kill_the_bloom/element_type.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';
import 'package:kill_the_bloom/player_state_type.dart';

class PlayerComponent extends SpriteAnimationComponent
    with KeyboardHandler, HasGameReference<KillTheBloomGame> {
  Vector2 velocity = Vector2.zero();
  final double speed = 1000;
  ElementType currentElement = ElementType.red;
  PlayerStateType currentState = PlayerStateType.idle;
  late Map<PlayerStateType, SpriteAnimation> animations;

  PlayerComponent();

  @override
  Future<void> onLoad() async {
    await _loadAnimations(currentElement);
    size = Vector2(48, 48);
    animation = animations[currentState]!;

    add(RectangleHitbox());

    final healthBar = HealthBarComponent(
      maxHealth: 3,
      currentHealth: 1,
      heartSize: Vector2(16, 16),
      heartsPerRow: 3,
      position: Vector2(0, -16), // 머리 위에 표시
    );
    add(healthBar);
  }

  @override
  void update(double dt) {
    position += velocity * speed * dt;

    // 화면 밖 못 나가게 제한
    // Anchor.center 기준의 clamp
    final halfSize = size / 2;
    final min = Vector2(0 + halfSize.x, 0 + halfSize.y);
    final max = Vector2(game.size.x - halfSize.x, game.size.y - halfSize.y);
    position.clamp(min, max);

    if (animation != null &&
        animationTicker?.done() == true &&
        currentState == PlayerStateType.attack) {
      setState(
        velocity.length > 0 ? PlayerStateType.move : PlayerStateType.idle,
      );
    }

    if (currentState != PlayerStateType.attack) {
      setState(
        velocity.length > 0 ? PlayerStateType.move : PlayerStateType.idle,
      );
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      shoot();
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      velocity.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      velocity.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      velocity.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      velocity.x = 1;
    }

    if (velocity.length > 0) {
      velocity.normalize();
    }

    return true;
  }

  void changeElement(ElementType newElement) async {
    if (currentElement == newElement) return;
    currentElement = newElement;
    await _loadAnimations(newElement);
    animation = animations[currentState]!;
  }

  void setState(PlayerStateType newState) {
    if (currentState == newState) return;
    currentState = newState;
    animation = animations[currentState]!;
  }

  Future<void> _loadAnimations(ElementType type) async {
    final (filename, frameCount) = switch (type) {
      ElementType.red => ('dino/dinoSprites_red.png', 24),
      ElementType.green => ('dino/dinoSprites_green.png', 24),
      ElementType.blue => ('dino/dinoSprites_blue.png', 24),
    };

    final image = await game.images.load(filename);
    animations = {
      PlayerStateType.idle: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(0, 0),
        ),
      ),
      PlayerStateType.move: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.08,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(24 * 4, 0),
        ),
      ),
      PlayerStateType.attack: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.05,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(24 * 14, 0),
          loop: false,
        ),
      ),
    };
  }

  void shoot() {
    setState(PlayerStateType.attack);

    final bulletDirection = Vector2(1, 0);
    final spawnPosition = position + Vector2(24, 0);

    final bullet = BulletComponent(
      type: currentElement,
      position: spawnPosition,
      direction: bulletDirection,
    );

    game.world.add(bullet);
  }
}
