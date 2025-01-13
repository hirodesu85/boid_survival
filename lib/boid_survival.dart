import 'package:boid_survival/components/boid.dart';
import 'package:boid_survival/components/enemies/random_enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BoidSurvivalGame extends FlameGame with HasCollisionDetection {
  // ボイドの調節不能パラメータ
  int boidCount = 10;
  int random = 3;

  // ボイドの調節可能パラメータ
  int separation = 100;
  int alignment = 30;
  int cohesion = 60;
  int speed = 100;
  int sight = 70;
  int escape = 50;

  // Wave関連
  int currentWave = 1;
  double waveDuration = 20.0; // 各Waveの長さ（秒）
  double waveTimer = 20.0; // 現在のWaveの残り時間

  // ValueNotifier
  final ValueNotifier<int> waveNotifier = ValueNotifier(1); // 初期Waveは1
  final ValueNotifier<double> timerNotifier = ValueNotifier(20.0); // 初期残り時間は30秒

  // ゲーム状態
  bool isGameOver = false;

  // ゲームエリア
  double headerHeight = 120;
  late Rect gameArea;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'boid.png',
      'random_enemy.png',
    ]);

    // ゲームエリアを設定
    gameArea = Rect.fromLTWH(0, headerHeight, size.x, size.y - headerHeight);

    startWave();

    // 衝突判定を有効化
    add(ScreenHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    // Waveタイマーを更新
    waveTimer -= dt;
    timerNotifier.value = waveTimer;

    // Wave終了判定
    if (waveTimer <= 0) {
      if (boidCount > 0) {
        // 次のWaveへ進む
        currentWave++;
        waveNotifier.value = currentWave;
        startWave();
      } else {
        endGame();
      }
    }
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void startWave() {
    waveTimer = waveDuration;
    spawnBoids();
    spawnEnemies();
  }

  void endGame() {
    isGameOver = true;
    overlays.add('GameOver');
    overlays.remove('Header');
  }

  void spawnBoids() {
    for (int i = 0; i < boidCount; i++) {
      add(Boid(
        position: Vector2.random()..multiply(size - Vector2.all(24)),
      ));
    }
  }

  void spawnEnemies() {
    int enemyCount = currentWave;
    for (int i = 0; i < enemyCount; i++) {
      add(RandomEnemy(
        position: Vector2.random()..multiply(size - Vector2.all(32)),
      ));
    }
  }
}
