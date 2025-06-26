import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/enemy_state_type.dart';
import 'package:kill_the_bloom/element_type.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';

class EnemyComponent extends SpriteAnimationComponent
    with HasGameReference<KillTheBloomGame>, CollisionCallbacks {
  EnemyStateType currentState = EnemyStateType.idle;
  late final Map<EnemyStateType, SpriteAnimation> animations;
  bool isDead = false;
  ElementType currentWeakness = ElementType.red;
  late TimerComponent _phaseTimer;
  bool _isEffectPhase = false;

  EnemyComponent({super.position}) {
    size = Vector2(256, 256);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    animations = {
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

    animation = animations[EnemyStateType.idle];
    add(RectangleHitbox());

    _startPhaseLoop();
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

  void takeDamage() {
    if (isDead) return;
    animation = animations[EnemyStateType.hurt];
    animationTicker?.onComplete = () {
      animation = animations[EnemyStateType.idle];
    };
  }

  void die() {
    if (isDead) return;
    isDead = true;
    animation = animations[EnemyStateType.death];
    animationTicker?.onComplete = () {
      removeFromParent();
    };
  }

  void _startPhaseLoop() {
    _scheduleNextPhase();
  }

  void _scheduleNextPhase() {
    if (_isEffectPhase) {
      _isEffectPhase = false;
      _phaseTimer = TimerComponent(period: 5, onTick: _scheduleNextPhase);
      _onEffectEnd();
    } else {
      _isEffectPhase = true;
      final duration = Random().nextInt(10) + 1;
      _phaseTimer = TimerComponent(
        period: duration.toDouble(),
        onTick: _scheduleNextPhase,
      );
      _onEffectStart();
    }
    add(_phaseTimer);
  }

  void _onEffectStart() {
    // 새로운 약점 색상 설정
    final available =
        ElementType.values.where((e) => e != currentWeakness).toList();
    available.shuffle();
    currentWeakness = available.first;

    final color = switch (currentWeakness) {
      ElementType.red => Colors.red,
      ElementType.green => Colors.green,
      ElementType.blue => Colors.blue,
    };

    // 기존 이펙트 제거 후 새로운 컬러 이펙트 추가
    children.whereType<ColorEffect>().forEach(remove);
    add(
      ColorEffect(
        color,
        EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true),
        opacityTo: 0.8,
      ),
    );
  }

  void _onEffectEnd() {
    children.whereType<ColorEffect>().forEach(remove);
    if (game.player.currentElement != currentWeakness) {
      // game.player.die();
    }
  }
}
