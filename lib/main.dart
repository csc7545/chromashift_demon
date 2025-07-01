import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:chromashift_demon/chromashift_demon_game.dart';
import 'package:chromashift_demon/overlays/game_over_overlay.dart';
import 'package:chromashift_demon/overlays/game_start_overlay.dart';

void main() {
  runApp(
    GameWidget(
      game: ChromaShiftDemonGame(),
      overlayBuilderMap: {
        'GameStartOverlay':
            (context, game) =>
                GameStartOverlay(game: game as ChromaShiftDemonGame),
        'GameOverOverlay':
            (context, game) => GameOverOverlay(
              game: game as ChromaShiftDemonGame,
              isVictory: game.isVictory,
              score: game.finalScore,
            ),
      },
    ),
  );
}
