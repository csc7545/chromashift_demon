import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chromashift_demon/chromashift_demon_game.dart';

class GameStartOverlay extends StatelessWidget {
  final ChromaShiftDemonGame game;

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
                'assets/images/chromashift_demon_logo.png',
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
