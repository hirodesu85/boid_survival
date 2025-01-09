import 'package:boid_survival/boid_survival.dart';
import 'package:flame/components.dart';

class Boid extends SpriteAnimationComponent
    with HasGameReference<BoidSurvivalGame> {
  Boid({
    required super.position,
  }) : super(size: Vector2.all(24), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('boid.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(16),
        stepTime: 0.24,
      ),
    );
  }
}
