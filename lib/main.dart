import 'package:boid_survival/overlays/game_over.dart';
import 'package:boid_survival/overlays/header.dart';
import 'package:boid_survival/overlays/parameter_adjustment.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:boid_survival/boid_survival.dart';

void main() {
  runApp(
    GameWidget<BoidSurvivalGame>.controlled(
      gameFactory: BoidSurvivalGame.new,
      overlayBuilderMap: {
        'Header': (context, game) {
          return ValueListenableBuilder<int>(
            valueListenable: game.waveNotifier,
            builder: (context, wave, child) {
              return ValueListenableBuilder<double>(
                valueListenable: game.timerNotifier,
                builder: (context, timeLeft, child) {
                  return HeaderOverlay(
                    wave: wave,
                    timeLeft: timeLeft,
                  );
                },
              );
            },
          );
        },
        'GameOver': (context, game) {
          return GameOverOverlay(
            onRestart: () {
              game.restartGame(); // ゲームをリスタート
              game.overlays.remove('GameOver'); // オーバーレイを削除
              game.overlays.add('ParameterAdjustment'); // パラメータ調整画面を表示
            },
            result: game.currentWave,
          );
        },
        'ParameterAdjustment': (context, game) {
          return ValueListenableBuilder<Map<String, int>>(
            valueListenable: game.parametersNotifier,
            builder: (context, parameters, child) {
              return ValueListenableBuilder<int>(
                valueListenable: game.pointsNotifier,
                builder: (context, pointsRemaining, child) {
                  return ParameterAdjustmentOverlay(
                    parameters: parameters,
                    nextWave: game.currentWave,
                    pointsRemaining: pointsRemaining,
                    onParameterIncrease: game.increaseParameter,
                  );
                },
              );
            },
          );
        },
      },
      initialActiveOverlays: const ['ParameterAdjustment'],
    ),
  );
}
