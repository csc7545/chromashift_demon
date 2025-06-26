import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/components/element_changer_component.dart';
import 'package:kill_the_bloom/components/enemy_component.dart';
import 'package:kill_the_bloom/components/player_component.dart';
import 'package:kill_the_bloom/components/world_border_component.dart';
import 'package:kill_the_bloom/element_type.dart';

class KillTheBloomGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final PlayerComponent player;
  late final EnemyComponent enemy;

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
    camera.viewfinder.anchor = Anchor.topLeft;
    addAll([camera, world]);

    player = PlayerComponent()..position = Vector2(size.x - 1000, size.y / 2);
    enemy = EnemyComponent(position: Vector2(size.x - 256, size.y / 2));

    world.add(player);
    world.add(enemy);
    world.add(WorldBorderComponent(size: Vector2(1280, 620)));

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
      random.nextDouble() * 640,
      random.nextDouble() * 360,
    );

    final changer = ElementChangerComponent(
      type: randomType,
      position: position,
      onCollected: () {
        spawnedTypes.remove(randomType);
        spawnRandomElementChanger();
      },
    );

    spawnedTypes.add(randomType);
    world.add(changer);
  }
}
