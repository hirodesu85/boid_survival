import 'package:boid_survival/boid_survival.dart';
import 'package:boid_survival/components/boid.dart';
import 'package:boid_survival/components/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TrackingEnemy extends SpriteAnimationComponent
    with Enemy, CollisionCallbacks, HasGameReference<BoidSurvivalGame> {
  Vector2 velocity = Vector2.zero();
  double speed = 50;

  TrackingEnemy({
    required super.position,
  }) : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('tracking_enemy.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(64),
        stepTime: 0.24,
      ),
    );
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 最も近いボイドを探す
    Boid? targetBoid = _findClosestBoid();

    if (targetBoid != null) {
      // ターゲットに向かう方向を計算
      Vector2 direction = (targetBoid.position - position).normalized();
      velocity = direction * speed;

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
    if (other is Boid) {
      game.remove(other); // ボイドを削除
    }
  }

  Boid? _findClosestBoid() {
    List<Boid> boids = game.children.whereType<Boid>().toList();
    Boid? closestBoid;
    double closestDistance = double.infinity;

    for (Boid boid in boids) {
      double distance = (boid.position - position).length;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestBoid = boid;
      }
    }

    return closestBoid;
  }

  void _checkBounds() {
    // ゲームエリアを取得
    final Rect gameArea = game.gameArea;

    // 境界チェックと位置補正
    if (position.x < gameArea.left) {
      position.x = gameArea.left;
      velocity.x = velocity.x.abs();
    } else if (position.x > gameArea.right) {
      position.x = gameArea.right;
      velocity.x = -velocity.x.abs();
    }

    if (position.y < gameArea.top) {
      position.y = gameArea.top;
      velocity.y = velocity.y.abs();
    } else if (position.y > gameArea.bottom) {
      position.y = gameArea.bottom;
      velocity.y = -velocity.y.abs();
    }
  }
}
