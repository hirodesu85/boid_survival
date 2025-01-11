import 'package:boid_survival/components/boid.dart';
import 'package:boid_survival/components/enemies/random_enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BoidSurvivalGame extends FlameGame with HasCollisionDetection {
  // ボイドの調節不能パラメータ
  int boidCount = 10;
  int random = 1;

  // ボイドの調節可能パラメータ
  int separation = 100;
  int alignment = 30;
  int cohesion = 60;
  int speed = 100;
  int sight = 70;
  int escape = 10;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'boid.png',
      'random_enemy.png',
    ]);

    // ボイドの生成を行う
    for (int i = 0; i < boidCount; i++) {
      add(Boid(
        position: Vector2.random()..multiply(size - Vector2.all(24)),
      ));
    }

    // 敵の生成を行う
    add(RandomEnemy(
      position: Vector2.random()..multiply(size - Vector2.all(32)),
    ));

    // 衝突判定を有効化
    add(ScreenHitbox());
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}
