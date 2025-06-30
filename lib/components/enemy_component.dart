import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/components/enemy_bullet_component.dart';
import 'package:kill_the_bloom/components/heart_bar_component.dart';
import 'package:kill_the_bloom/enemy_state_type.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';
import 'package:kill_the_bloom/element_type.dart';
import 'package:kill_the_bloom/player_state_type.dart';

class EnemyComponent extends SpriteAnimationComponent
    with HasGameReference<KillTheBloomGame>, CollisionCallbacks {
  EnemyStateType currentState = EnemyStateType.idle;
  late final Map<EnemyStateType, SpriteAnimation> animations;

  bool isDead = false;
  bool hasFired = false;
  int lastFrameIndex = -1;
  ElementType? currentColor;

  // Heath
  late final HealthBarComponent healthBar;
  int maxHealth = 50;
  int currentHealth = 50;

  EnemyComponent({super.position}) {
    size = Vector2(243, 213);
  }

  @override
  Future<void> onLoad() async {
    healthBar = HealthBarComponent(
      maxHealth: maxHealth,
      currentHealth: currentHealth,
      heartSize: Vector2(16, 16),
      heartsPerRow: 10,
      position: Vector2(16, (-16 * 6)), // 머리 위에 표시
    );

    animations = {
      EnemyStateType.charging: await _loadSingleFrameAnimation(
        path: 'demon/demon_hurt.png',
        frameIndex: 2, // 세 번째 프레임 (0부터 시작)
        frameSize: Vector2(81, 71),
      ),
      EnemyStateType.attacking: await _loadAnimation(
        'demon/demon_attack.png',
        8,
        Vector2(81, 71),
        loop: false,
      ),
      EnemyStateType.idle: await _loadAnimation(
        'demon/demon_idle.png',
        4,
        Vector2(81, 71),
      ),
      EnemyStateType.hurt: await _loadAnimation(
        'demon/demon_hurt.png',
        4,
        Vector2(81, 71),
        loop: false,
      ),
      EnemyStateType.death: await _loadAnimation(
        'demon/demon_death.png',
        7,
        Vector2(81, 71),
        loop: false,
      ),
    };

    _startChargingPhase();
    add(RectangleHitbox());
    add(healthBar);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentState == EnemyStateType.attacking && animationTicker != null) {
      final currentFrameIndex = animationTicker!.currentIndex;

      if (currentFrameIndex == 3 && !hasFired) {
        _fireBulletOnce();
        hasFired = true;
      }

      lastFrameIndex = currentFrameIndex;
    }
  }

  // Charging
  void _startChargingPhase() async {
    currentState = EnemyStateType.charging;
    animation = animations[EnemyStateType.charging];
    add(TimerComponent(period: 5, onTick: _startActivePhase));
  }

  // Color Active
  void _startActivePhase() {
    currentState = EnemyStateType.active;
    currentColor =
        ElementType.values[Random().nextInt(ElementType.values.length)];
    // 랜덤 지속 시간 (5~10초)
    final duration = Random().nextInt(5) + 5;

    children.whereType<ColorEffect>().forEach(remove);
    add(
      ColorEffect(
        _getColorFromElement(currentColor!),
        EffectController(
          duration: duration / 20,
          reverseDuration: duration / 20,
          infinite: true,
        ),
        opacityTo: 0.8,
      ),
    );

    add(TimerComponent(period: duration.toDouble(), onTick: _startIdlePhase));
  }

  // Idle
  void _startIdlePhase() {
    children.whereType<ColorEffect>().forEach(remove);

    if (game.player.currentElement != currentColor) {
      _maybeAttack(); // 바로 공격 상태로 전환
      return;
    }

    currentState = EnemyStateType.idle;
    animation = animations[EnemyStateType.idle];

    // 움직임 감시 + 타이머 병렬 실행
    _monitorPlayerMovementDuringIdle();
  }

  void _maybeAttack() {
    currentState = EnemyStateType.attacking;
    animation = animations[EnemyStateType.attacking];
    hasFired = false;
    lastFrameIndex = -1;

    animationTicker?.onComplete = () {
      animation = animations[EnemyStateType.idle];
    };
    add(TimerComponent(period: 5, onTick: _startChargingPhase));
  }

  void _fireBulletOnce() {
    final mouthOffset = Vector2(-50, 20);
    final startPosition = position + mouthOffset;

    final bullet = EnemyBulletComponent(startPosition: startPosition);
    game.world.add(bullet);
  }

  void _monitorPlayerMovementDuringIdle() {
    children.whereType<ColorEffect>().forEach(remove);
    final initialPosition = game.player.position.clone();

    // 5초 내로 이동 감지되면 공격, 아니면 charging
    add(
      TimerComponent(
        period: 5,
        onTick: () {
          if ((game.player.position - initialPosition).length > 2 ||
              game.player.currentState == PlayerStateType.attack) {
            _maybeAttack(); // 이동했으므로 공격
          } else {
            _startChargingPhase(); // 움직이지 않았으므로 charging
          }
        },
      ),
    );
  }

  Color _getColorFromElement(ElementType type) {
    switch (type) {
      case ElementType.red:
        return Colors.red;
      case ElementType.green:
        return Colors.green;
      case ElementType.blue:
        return Colors.blue;
    }
  }

  Future<SpriteAnimation> _loadAnimation(
    String path,
    int amount,
    Vector2 frameSize, {
    bool loop = true,
  }) async {
    final image = await game.images.load(path);
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.15,
        textureSize: frameSize,
        loop: loop,
      ),
    );
  }

  Future<SpriteAnimation> _loadSingleFrameAnimation({
    required String path,
    required int frameIndex,
    required Vector2 frameSize,
  }) async {
    final image = await game.images.load(path);
    return SpriteAnimation.spriteList(
      [
        Sprite(
          image,
          srcPosition: Vector2(frameSize.x * frameIndex, 0),
          srcSize: frameSize,
        ),
      ],
      stepTime: double.infinity, // 무한히 정지
    );
  }

  void takeDamage(ElementType bulletColor) {
    if (isDead || currentState != EnemyStateType.active) return;

    // 발사체 색상과 현재 약점 색상이 일치하지 않으면 무효
    if (currentColor != bulletColor) return;

    currentHealth--;
    healthBar.updateHealth(currentHealth);

    if (currentHealth <= 0) {
      die();
      return;
    }

    animation = animations[EnemyStateType.hurt];
    animationTicker?.onComplete = () {
      animation = animations[EnemyStateType.charging];
    };
  }

  void die() {
    if (isDead) return;
    children.whereType<ColorEffect>().forEach(remove);

    currentState = EnemyStateType.death;
    isDead = true;
    animation = animations[EnemyStateType.death];
    animationTicker?.onComplete = () {
      removeFromParent();
    };
  }
}
