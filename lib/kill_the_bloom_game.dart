import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/components/element_changer_component.dart';
import 'package:kill_the_bloom/components/enemy_component.dart';
import 'package:kill_the_bloom/components/player_component.dart';
import 'package:kill_the_bloom/components/score_hud_component.dart';
import 'package:kill_the_bloom/components/world_border_component.dart';
import 'package:kill_the_bloom/element_type.dart';

class KillTheBloomGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final PlayerComponent player;
  late final EnemyComponent enemy;
  late final WorldBorderComponent worldBorder;
  late final ScoreHudComponent scoreHud;

  @override
  bool debugMode = true;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 64, 61, 61);

  @override
  Future<void> onLoad() async {
    world = World();
    camera = CameraComponent.withFixedResolution(
      width: 1280,
      height: 620,
      world: world,
    );

    player =
        PlayerComponent()
          ..anchor = Anchor.center
          ..position = Vector2(size.x / 2 - 300, size.y / 2); // 화면 왼쪽에 위치
    enemy =
        EnemyComponent()
          ..anchor = Anchor.center
          ..position = Vector2(size.x / 2 + 300, size.y / 2); // 화면 오른쪽에 위치

    worldBorder = WorldBorderComponent(size: Vector2(1280, 620));
    scoreHud = ScoreHudComponent();

    addAll([camera, world]);
    world.add(player);
    world.add(enemy);
    world.add(worldBorder);
    world.add(scoreHud);

    camera.viewfinder.anchor = Anchor.topLeft;
    // camera.follow(player);

    for (int i = 0; i < 3; i++) {
      spawnRandomElementChanger();
    }
  }

  final Set<ElementType> spawnedTypes = {};

  void spawnRandomElementChanger() {
    final random = Random();
    final available =
        ElementType.values.where((e) => !spawnedTypes.contains(e)).toList();
    if (available.isEmpty) return;

    final randomType = available[random.nextInt(available.length)];

    final position = Vector2(
      random.nextDouble() * 700,
      random.nextDouble() * 500,
    );

    final changer = ElementChangerComponent(
      type: randomType,
      position: position,
      onCollected: () {
        scoreHud.increaseScore(100);
        spawnedTypes.remove(randomType);
        spawnRandomElementChanger();
      },
    );

    spawnedTypes.add(randomType);
    world.add(changer);
  }
}
