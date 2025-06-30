import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kill_the_bloom/kill_the_bloom_game.dart';

class GameStartOverlay extends StatelessWidget {
  final KillTheBloomGame game;

  const GameStartOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'images/chromashift_demon_logo.png', // 저장한 로고 경로
                width: 500,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: game.startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(32),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.black54,
                  textStyle: GoogleFonts.pressStart2p(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // 픽셀 느낌
                  ),
                ),
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
