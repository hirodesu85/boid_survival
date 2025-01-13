import 'package:boid_survival/overlays/header.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:boid_survival/boid_survival.dart';

void main() {
  runApp(
    GameWidget<BoidSurvivalGame>.controlled(
      gameFactory: BoidSurvivalGame.new,
      overlayBuilderMap: {
        // ヘッダーオーバーレイ
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
      },
      initialActiveOverlays: const ['Header'],
    ),
  );
}
