import 'dart:math';

import 'package:boid_survival/boid_survival.dart';
import 'package:flame/components.dart';

class Boid extends SpriteAnimationComponent
    with HasGameReference<BoidSurvivalGame> {
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
  }

  @override
  void update(double dt) {
    super.update(dt);

    // BoidSurvivalGame から調節可能パラメータを取得
    int alignment = game.alignment;
    int cohesion = game.cohesion;
    int separation = game.separation;
    int speed = game.speed;
    int sight = game.sight;
    int random = game.random;

    // 近くのボイドを探す
    List<Boid> neighbors = _findNeighbors(sight);

    // 各種力を計算
    Vector2 alignmentForce =
        _calculateAlignment(neighbors) * alignment.toDouble();
    Vector2 cohesionForce = _calculateCohesion(neighbors) * cohesion.toDouble();
    Vector2 separationForce =
        _calculateSeparation(neighbors) * separation.toDouble();
    Vector2 randomForce = _applyRandomForce() * random.toDouble();

    // 全ての力を合算
    velocity += alignmentForce + cohesionForce + separationForce + randomForce;

    // 速度を制限
    if (velocity.length > speed) {
      velocity = velocity.normalized() * speed.toDouble();
    }

    // 境界をチェック
    _checkBounds();

    // 向きを決定
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontally();
    }

    // 位置を更新
    position += velocity * dt;
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

    return (averageVelocity - velocity) * 0.05;
  }

  Vector2 _calculateCohesion(List<Boid> neighbors) {
    if (neighbors.isEmpty) return Vector2.zero();

    Vector2 averagePosition = Vector2.zero();
    for (var neighbor in neighbors) {
      averagePosition += neighbor.position;
    }
    averagePosition /= neighbors.length.toDouble();

    return (averagePosition - position) * 0.01;
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

    return separationForce * 0.1;
  }

  Vector2 _applyRandomForce() {
    // ランダムな方向の力を生成
    final random = Random();
    double angle = random.nextDouble() * 2 * pi; // 0〜360度のランダム角度
    return Vector2(cos(angle), sin(angle)); // ランダムな方向ベクトル
  }

  void _checkBounds() {
    // 画面の境界を取得
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    // 左端または右端を超えそうになった場合
    if (position.x <= 0 || position.x >= screenWidth) {
      velocity.x = -velocity.x; // X方向の速度を反転
    }

    // 上端または下端を超えそうになった場合
    if (position.y <= 0 || position.y >= screenHeight) {
      velocity.y = -velocity.y; // Y方向の速度を反転
    }
  }
}
