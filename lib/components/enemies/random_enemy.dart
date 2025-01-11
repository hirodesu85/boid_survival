import 'dart:math';
import 'package:boid_survival/boid_survival.dart';
import 'package:boid_survival/components/boid.dart';
import 'package:boid_survival/components/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class RandomEnemy extends SpriteAnimationComponent
    with Enemy, CollisionCallbacks, HasGameReference<BoidSurvivalGame> {
  Vector2 velocity = Vector2(
    Random().nextDouble() * 2 - 1,
    Random().nextDouble() * 2 - 1,
  );
  double speed = 150;

  RandomEnemy({
    required super.position,
  }) : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('random_enemy.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(32),
        stepTime: 0.24,
      ),
    );
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ランダムな速度を生成
    velocity += Vector2(
      Random().nextDouble() * 2 - 1,
      Random().nextDouble() * 2 - 1,
    );

    // 速度を制限
    if (velocity.length > speed) {
      velocity = velocity.normalized() * speed.toDouble();
    }

    // 向きを決定
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontally();
    }

    // 位置を更新
    position += velocity * dt;

    // 画面の境界を超えていないかチェック
    _checkBounds();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // 画面境界との衝突
    if (other is ScreenHitbox) {
      if (intersectionPoints.isNotEmpty) {
        final collisionPoint = intersectionPoints.first;
        final collisionNormal = (absoluteCenter - collisionPoint).normalized();
        velocity = velocity.reflected(collisionNormal);
        position += collisionNormal * 1.0;
      }
    }

    // ボイドとの衝突
    // 衝突したボイドを削除する
    if (other is Boid) {
      game.remove(other);
      game.boidCount--;
    }
  }

  void _checkBounds() {
    // 画面の境界を取得
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    // 境界チェックの余裕（オフセット）を設定
    const double boundaryOffset = 20.0;

    if (position.x <= boundaryOffset ||
        position.x >= screenWidth - boundaryOffset) {
      velocity.x = -velocity.x;
    }
    if (position.y <= boundaryOffset ||
        position.y >= screenHeight - boundaryOffset) {
      velocity.y = -velocity.y;
    }
  }
}
