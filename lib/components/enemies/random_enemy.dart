import 'dart:math';
import 'package:boid_survival/boid_survival.dart';
import 'package:boid_survival/components/boid.dart';
import 'package:boid_survival/components/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RandomEnemy extends SpriteAnimationComponent
    with Enemy, CollisionCallbacks, HasGameReference<BoidSurvivalGame> {
  Vector2 velocity = Vector2.zero();
  double speed = 50;

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
        ).normalized() *
        (speed / 4);

    // 速度調整
    velocity = velocity.normalized() * speed;

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
    }
  }

  void _checkBounds() {
    // ゲームエリアを取得
    final Rect gameArea = game.gameArea;

    // 境界チェックと位置補正
    if (position.x < gameArea.left) {
      position.x = gameArea.left;
      velocity.x = velocity.x.abs(); // 右方向に反転
    } else if (position.x > gameArea.right) {
      position.x = gameArea.right;
      velocity.x = -velocity.x.abs(); // 左方向に反転
    }

    if (position.y < gameArea.top) {
      position.y = gameArea.top;
      velocity.y = velocity.y.abs(); // 下方向に反転
    } else if (position.y > gameArea.bottom) {
      position.y = gameArea.bottom;
      velocity.y = -velocity.y.abs(); // 上方向に反転
    }
  }
}
