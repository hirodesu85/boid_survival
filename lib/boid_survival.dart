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
  double waveDuration = 10.0; // 各Waveの長さ（秒）
  double waveTimer = 10.0; // 現在のWaveの残り時間

  // ValueNotifier
  final ValueNotifier<int> waveNotifier = ValueNotifier(1); // 初期Waveは1
  final ValueNotifier<double> timerNotifier = ValueNotifier(10.0); // 初期残り時間は20秒
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

    // Wave終了判定
    if (boidCount == 0) {
      endGame();
    }

    if (waveTimer <= 0) {
      if (boidCount > 0) {
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
      'separation': 100,
      'alignment': 30,
      'cohesion': 60,
      'speed': 100,
      'sight': 70,
      'escape': 50,
    };

    // ポイントをリセット
    pointsRemaining = 10;
    pointsNotifier.value = pointsRemaining;

    // パラメータ強化画面を表示
    startParameterAdjustment();
  }

  void spawnBoids() {
    boidCount = 10;
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
