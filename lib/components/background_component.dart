import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class BackgroundComponent extends SpriteComponent {
  BackgroundComponent({required Vector2 size})
    : super(
        size: size,
        position: Vector2.zero(),
        priority: -1, // 맨 뒤에 그려지도록
      );

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await Flame.images.load('background.png'));
  }
}
