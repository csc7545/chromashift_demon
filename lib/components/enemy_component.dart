import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/enemy_state_type.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';
import 'package:kill_the_bloom/element_type.dart';

class EnemyComponent extends SpriteAnimationComponent
    with HasGameReference<KillTheBloomGame>, CollisionCallbacks {
  EnemyStateType currentState = EnemyStateType.idle;
  late final Map<EnemyStateType, SpriteAnimation> animations;

  bool isDead = false;
  ElementType? currentColor;

  EnemyComponent({super.position}) {
    size = Vector2(256, 256);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    animations = {
      EnemyStateType.charging: await _loadSingleFrameAnimation(
        path: 'demon/demon_hurt.png',
        frameIndex: 2, // 세 번째 프레임 (0부터 시작)
        frameSize: Vector2(81, 81),
      ),
      EnemyStateType.attacking: await _loadAnimation(
        'demon/demon_attack.png',
        8,
        Vector2(81, 81),
      ),
      EnemyStateType.idle: await _loadAnimation(
        'demon/demon_idle.png',
        4,
        Vector2(81, 81),
      ),
      EnemyStateType.hurt: await _loadAnimation(
        'demon/demon_hurt.png',
        4,
        Vector2(81, 81),
        loop: false,
      ),
      EnemyStateType.death: await _loadAnimation(
        'demon/demon_death.png',
        7,
        Vector2(81, 81),
        loop: false,
      ),
    };

    _startChargingPhase();
    add(RectangleHitbox());
  }

  void _startChargingPhase() async {
    currentState = EnemyStateType.charging;
    animation = animations[EnemyStateType.charging];
    add(TimerComponent(period: 5, onTick: _startActivePhase));
  }

  void _startActivePhase() {
    currentState = EnemyStateType.active;
    // 랜덤 컬러 선택
    currentColor =
        ElementType.values[Random().nextInt(ElementType.values.length)];

    // 기존 이펙트 제거 후 컬러 이펙트 추가
    children.whereType<ColorEffect>().forEach(remove);
    add(
      ColorEffect(
        _getColorFromElement(currentColor!),
        EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true),
        opacityTo: 0.8,
      ),
    );

    // 랜덤 지속 시간 (5~10초)
    final duration = Random().nextInt(5) + 5;
    add(TimerComponent(period: duration.toDouble(), onTick: _startIdlePhase));
  }

  void _startIdlePhase() {
    currentState = EnemyStateType.idle;
    children.whereType<ColorEffect>().forEach(remove);

    animation = animations[EnemyStateType.idle]; // 날라다니는 상태

    // 조건 체크 후 공격 혹은 다음 충전
    add(TimerComponent(period: 5, onTick: _maybeAttack));
  }

  void _maybeAttack() {
    currentState = EnemyStateType.attacking;
    // TODO: 플레이어 움직였는지 / 못 맞췄는지 체크해서 공격할지 결정
    animation = animations[EnemyStateType.attacking];

    // 일단 상태만 전환, 이후 발사체 로직 추가 예정
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

    animation = animations[EnemyStateType.hurt];
    animationTicker?.onComplete = () {
      animation = animations[EnemyStateType.idle];
    };
  }

  void die() {
    if (isDead) return;

    currentState = EnemyStateType.death;
    isDead = true;
    animation = animations[EnemyStateType.death];
    animationTicker?.onComplete = () {
      removeFromParent();
    };
  }
}
