import 'package:flame/components.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chromashift_demon/utils/rainbow_color_util.dart'; // 유틸 import

class ScoreHudComponent extends TextComponent {
  int score = 0;
  double time = 0;

  ScoreHudComponent()
    : super(
        text: 'Score: 0',
        position: Vector2(16, 16),
        anchor: Anchor.topLeft,
        priority: 100,
      ) {
    textRenderer = TextPaint(
      style: GoogleFonts.pressStart2p(
        color: RainbowColorUtil.getColor(0),
        fontSize: 24,
      ),
    );
  }

  void increaseScore(int amount) {
    score += amount;
    text = 'Score: $score';
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    final newColor = RainbowColorUtil.getColor(time * 2);
    textRenderer = TextPaint(
      style: GoogleFonts.pressStart2p(color: newColor, fontSize: 24),
    );
  }
}
