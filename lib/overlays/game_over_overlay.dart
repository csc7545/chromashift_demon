import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chromashift_demon/chromashift_demon_game.dart';

class GameOverOverlay extends StatelessWidget {
  final ChromaShiftDemonGame game;
  final bool isVictory;
  final int score;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.isVictory,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 4),
          color: Colors.black45,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isVictory ? '🎉 VICTORY' : '💀 GAME OVER',
              style: GoogleFonts.pressStart2p(
                fontSize: 40,
                color: Colors.redAccent,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.white,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SCORE: $score',
              style: GoogleFonts.pressStart2p(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () {
                game.resetGame();
                game.overlays.remove('GameOverOverlay');
                game.overlays.add('GameStartOverlay');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // 픽셀 느낌
                ),
              ),
              child: Text(
                'RESTART',
                style: GoogleFonts.pressStart2p(fontSize: 16, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
