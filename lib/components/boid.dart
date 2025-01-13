import 'dart:math';
import 'package:boid_survival/boid_survival.dart';
import 'package:boid_survival/components/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Boid extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<BoidSurvivalGame> {
  Vector2 velocity = Vector2(
    Random().nextDouble() * 2 - 1,
    Random().nextDouble() * 2 - 1,
  );

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
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // BoidSurvivalGame から調節可能パラメータを取得
    int alignment = game.parameters['alignment']!;
    int cohesion = game.parameters['cohesion']!;
    int separation = game.parameters['separation']!;
    int speed = game.parameters['speed']! * 5;
    int sight = game.parameters['sight']! * 5;
    int escape = game.parameters['escape']!;

    // BoidSurvivalGame から調節不能パラメータを取得
    int random = game.random;

    // 近くのボイドを探す
    List<Boid> neighbors = _findNeighbors(sight);

    // 各種力を計算
    Vector2 alignmentForce =
        _normalizeForce(_calculateAlignment(neighbors), 1.0) *
            alignment.toDouble();
    Vector2 cohesionForce =
        _normalizeForce(_calculateCohesion(neighbors), 1.0) *
            cohesion.toDouble();
    Vector2 separationForce =
        _normalizeForce(_calculateSeparation(neighbors), 1.0) *
            separation.toDouble();
    Vector2 escapeForce =
        _normalizeForce(_applyEscapeForce(sight), 1.0) * escape.toDouble();
    Vector2 randomForce =
        _normalizeForce(_applyRandomForce(), 1.0) * random.toDouble();
    Vector2 wallForce = _normalizeForce(_applyWallForce(), 1.0) * 70.0;

    // 全ての力を合算
    velocity += alignmentForce +
        cohesionForce +
        separationForce +
        randomForce +
        wallForce +
        escapeForce;

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
  }

  List<Boid> _findNeighbors(int sight) {
    return game.children.whereType<Boid>().where((other) {
      return other != this &&
          (other.position - position).length <= sight.toDouble();
    }).toList();
  }

  Vector2 _calculateAlignment(List<Boid> neighbors) {
    if (neighbors.isEmpty) return Vector2.zero();

    Vector2 averageVelocity = Vector2.zero();
    for (var neighbor in neighbors) {
      averageVelocity += neighbor.velocity;
    }
    averageVelocity /= neighbors.length.toDouble();

    return (averageVelocity - velocity);
  }

  Vector2 _calculateCohesion(List<Boid> neighbors) {
    if (neighbors.isEmpty) return Vector2.zero();

    Vector2 averagePosition = Vector2.zero();
    for (var neighbor in neighbors) {
      averagePosition += neighbor.position;
    }
    averagePosition /= neighbors.length.toDouble();

    return (averagePosition - position);
  }

  Vector2 _calculateSeparation(List<Boid> neighbors) {
    if (neighbors.isEmpty) return Vector2.zero();

    Vector2 separationForce = Vector2.zero();
    for (var neighbor in neighbors) {
      Vector2 diff = position - neighbor.position;
      if (diff.length > 0) {
        separationForce += diff / diff.length; // 距離に反比例
      }
    }

    return separationForce;
  }

  Vector2 _applyRandomForce() {
    // ランダムな方向の力を生成
    final random = Random();
    double angle = random.nextDouble() * 2 * pi; // 0〜360度のランダム角度
    return Vector2(cos(angle), sin(angle)); // ランダムな方向ベクトル
  }

  Vector2 _applyWallForce() {
    // ゲームエリアを取得
    final Rect gameArea = game.gameArea;

    // 壁からの力を初期化
    Vector2 force = Vector2.zero();

    // 壁からの距離に応じて力を計算
    const double wallEffectRange = 100.0; // 力が有効になる距離

    // 左壁
    if (position.x - gameArea.left <= wallEffectRange) {
      double distance = max(1.0, position.x - gameArea.left); // 距離を1以上に制限
      force.x += 1 / distance; // 距離に反比例する力
    }

    // 右壁
    if (gameArea.right - position.x <= wallEffectRange) {
      double distance = max(1.0, gameArea.right - position.x);
      force.x -= 1 / distance;
    }

    // 上壁
    if (position.y - gameArea.top <= wallEffectRange) {
      double distance = max(1.0, position.y - gameArea.top);
      force.y += 1 / distance;
    }

    // 下壁
    if (gameArea.bottom - position.y <= wallEffectRange) {
      double distance = max(1.0, gameArea.bottom - position.y);
      force.y -= 1 / distance;
    }

    return force;
  }

  Vector2 _applyEscapeForce(int sight) {
    // 近くの敵を探す
    List<PositionComponent> enemies =
        game.children.whereType<PositionComponent>().where((enemy) {
      return enemy is Enemy &&
          (enemy.position - position).length <= sight.toDouble();
    }).toList();

    if (enemies.isEmpty) {
      return Vector2.zero();
    }

    // 敵から逃げる力を計算
    Vector2 escapeForce = Vector2.zero();
    for (var enemy in enemies) {
      Vector2 diff = position - enemy.position;
      double distance = diff.length;
      if (distance > 0) {
        escapeForce += diff / distance; // 距離に反比例する力
      }
    }

    return escapeForce; // 力のスケールを調整
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

  Vector2 _normalizeForce(Vector2 force, double targetLength) {
    if (force.length > targetLength) {
      return force.normalized() * targetLength;
    }
    return force;
  }
}
