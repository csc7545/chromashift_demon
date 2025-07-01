import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:chromashift_demon/components/background_component.dart';
import 'package:chromashift_demon/components/element_changer_component.dart';
import 'package:chromashift_demon/components/enemy_component.dart';
import 'package:chromashift_demon/components/player_component.dart';
import 'package:chromashift_demon/components/score_hud_component.dart';
import 'package:chromashift_demon/element_type.dart';

class ChromaShiftDemonGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  PlayerComponent? player;
  EnemyComponent? enemy;
  ScoreHudComponent? scoreHud;
  late final BackgroundComponent background;

  final Set<ElementType> spawnedTypes = {};
  bool gameStarted = false;
  bool gameOver = false;
  bool isVictory = false;
  int finalScore = 0;

  // @override
  // bool debugMode = true;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 64, 61, 61);

  @override
  Future<void> onLoad() async {
    world = World();
    camera = CameraComponent.withFixedResolution(
      width: 1280,
      height: 720,
      world: world,
    );

    background = BackgroundComponent(size: Vector2(1280, 720));

    addAll([camera, world]);
    world.add(background);

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    overlays.add('GameStartOverlay');
  }

  void startGame() {
    overlays.remove('GameStartOverlay');
    gameStarted = true;
    gameOver = false;
    finalScore = 0;
    resumeEngine();

    // 게임 초기화 로직
    player =
        PlayerComponent()
          ..anchor = Anchor.center
          ..position = Vector2(size.x / 2 - 300, size.y / 2); // 화면 왼쪽에 위치
    enemy =
        EnemyComponent()
          ..anchor = Anchor.center
          ..position = Vector2(size.x / 2 + 400, size.y / 2 + 50); // 화면 오른쪽에 위치

    scoreHud = ScoreHudComponent();

    world.add(player!);
    world.add(enemy!);
    world.add(scoreHud!);

    for (int i = 0; i < 3; i++) {
      spawnRandomElementChanger();
    }
  }

  void endGame({required bool victory}) {
    world.children
        .where((c) => c != background)
        .toList()
        .forEach((c) => c.removeFromParent());

    gameOver = true;
    isVictory = victory;
    finalScore = scoreHud!.score;
    overlays.add('GameOverOverlay');
  }

  void resetGame() {
    spawnedTypes.clear();

    gameStarted = false;
    gameOver = false;
    isVictory = false;
    finalScore = 0;
  }

  void spawnRandomElementChanger() {
    final random = Random();
    final available =
        ElementType.values.where((e) => !spawnedTypes.contains(e)).toList();

    final randomType = available[random.nextInt(available.length)];

    final centerY = size.y / 2;
    final position = Vector2(
      random.nextDouble() * 600,
      (centerY - 200) + random.nextDouble() * 400,
    );

    final changer = ElementChangerComponent(
      type: randomType,
      position: position,
      onCollected: () {
        scoreHud?.increaseScore(100);
        spawnedTypes.remove(randomType);
        spawnRandomElementChanger();
      },
    );

    spawnedTypes.add(randomType);
    world.add(changer);
  }
}
