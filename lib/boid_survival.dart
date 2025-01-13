import 'dart:math';

import 'package:boid_survival/components/boid.dart';
import 'package:boid_survival/components/enemies/random_enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BoidSurvivalGame extends FlameGame with HasCollisionDetection {
  // ボイドの調節不能パラメータ
  int random = 3;

  // ボイドの調節可能パラメータ
  int pointsRemaining = 10;
  Map<String, int> parameters = {
    'separation': 1,
    'alignment': 1,
    'cohesion': 1,
    'speed': 1,
    'sight': 1,
    'escape': 1,
  };

  // Wave関連
  int currentWave = 1;
  double waveDuration = 15.0; // 各Waveの長さ（秒）
  double waveTimer = 15.0; // 現在のWaveの残り時間

  // ValueNotifier
  final ValueNotifier<int> waveNotifier = ValueNotifier(1); // 初期Waveは1
  final ValueNotifier<double> timerNotifier = ValueNotifier(15.0); // 初期残り時間は20秒
  final ValueNotifier<Map<String, int>> parametersNotifier =
      ValueNotifier<Map<String, int>>({
    'separation': 1,
    'alignment': 1,
    'cohesion': 1,
    'speed': 1,
    'sight': 1,
    'escape': 1,
  });
  final ValueNotifier<int> pointsNotifier = ValueNotifier(10);

  // ゲーム状態
  bool isPaused = true;
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

    // 衝突判定を有効化
    add(ScreenHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;
    if (isPaused) return;

    // Waveタイマーを更新
    waveTimer -= dt;
    timerNotifier.value = waveTimer;

    // ゲームオーバー判定
    if (children.whereType<Boid>().isEmpty) {
      endGame();
      return;
    }

    if (waveTimer <= 0) {
      if (children.whereType<Boid>().isNotEmpty) {
        // 次のWaveへ進む
        currentWave++;
        waveNotifier.value = currentWave;

        // ボイドと敵を削除
        children.whereType<Boid>().toList().forEach(remove);
        children.whereType<RandomEnemy>().toList().forEach(remove);

        // パラメータ強化画面を表示
        startParameterAdjustment(); // パラメータ強化を開始
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
    isPaused = false;
    waveTimer = waveDuration;

    // ボイドと敵を生成
    spawnBoids();
    spawnEnemies();

    overlays.remove('ParameterAdjustment');
    overlays.add('Header');
  }

  void endGame() {
    isGameOver = true;
    overlays.add('GameOver');
    overlays.remove('Header');
  }

  void restartGame() {
    isGameOver = false;
    currentWave = 1;
    waveNotifier.value = 1;
    waveTimer = waveDuration;
    timerNotifier.value = waveTimer;

    // ボイドと敵を削除
    children.whereType<Boid>().toList().forEach(remove);
    children.whereType<RandomEnemy>().toList().forEach(remove);

    // パラメータをリセット
    parameters = {
      'separation': 1,
      'alignment': 1,
      'cohesion': 1,
      'speed': 1,
      'sight': 1,
      'escape': 1,
    };

    // ポイントをリセット
    pointsRemaining = 10;
    pointsNotifier.value = pointsRemaining;

    // パラメータ強化画面を表示
    startParameterAdjustment();
  }

  void spawnBoids() {
    for (int i = 0; i < 10; i++) {
      Vector2 position;
      do {
        position = Vector2(
          gameArea.left + Random().nextDouble() * gameArea.width,
          gameArea.top + Random().nextDouble() * gameArea.height,
        );
      } while (_isTooCloseToEnemies(position)); // 敵との距離をチェック

      add(Boid(position: position));
    }
  }

  void spawnEnemies() {
    int enemyCount = currentWave;
    for (int i = 0; i < enemyCount * 5; i++) {
      Vector2 position;
      do {
        position = Vector2(
          gameArea.left + Random().nextDouble() * gameArea.width,
          gameArea.top + Random().nextDouble() * gameArea.height,
        );
      } while (_isTooCloseToBoids(position)); // ボイドとの距離をチェック

      add(RandomEnemy(position: position));
    }
  }

  bool _isTooCloseToEnemies(Vector2 position) {
    return children.whereType<RandomEnemy>().any((enemy) {
      return (enemy.position - position).length < 100; // 100ピクセル以上離す
    });
  }

  bool _isTooCloseToBoids(Vector2 position) {
    return children.whereType<Boid>().any((boid) {
      return (boid.position - position).length < 50; // 50ピクセル以上離す
    });
  }

  void startParameterAdjustment() {
    isPaused = true;
    pointsRemaining = 10;
    parametersNotifier.value = Map<String, int>.from(parameters);
    pointsNotifier.value = pointsRemaining;
    overlays.remove('Header');
    overlays.add('ParameterAdjustment');
  }

  void increaseParameter(String key) {
    if (parameters.containsKey(key) && pointsRemaining > 0) {
      parameters[key] = parameters[key]! + 1;
      pointsRemaining--;

      // 通知
      parametersNotifier.value = Map<String, int>.from(parameters);
      pointsNotifier.value = pointsRemaining;

      if (pointsRemaining == 0) {
        startWave();
      }
    }
  }
}
