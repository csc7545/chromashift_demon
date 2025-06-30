import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';
import 'package:kill_the_bloom/overlays/game_over_overlay.dart';
import 'package:kill_the_bloom/overlays/game_start_overlay.dart';

void main() {
  runApp(
    GameWidget(
      game: KillTheBloomGame(),
      overlayBuilderMap: {
        'GameStartOverlay':
            (context, game) => GameStartOverlay(game: game as KillTheBloomGame),
        'GameOverOverlay':
            (context, game) => GameOverOverlay(
              game: game as KillTheBloomGame,
              isVictory: game.isVictory,
              score: game.finalScore,
            ),
      },
    ),
  );
}
