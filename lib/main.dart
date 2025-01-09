import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:boid_survival/boid_survival.dart';

void main() {
  runApp(
    const GameWidget<BoidSurvivalGame>.controlled(
      gameFactory: BoidSurvivalGame.new,
    ),
  );
}
