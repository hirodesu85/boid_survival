import 'package:boid_survival/components/boid.dart';
import 'package:flame/game.dart';

class BoidSurvivalGame extends FlameGame {
  late Boid _boid;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'boid.png',
    ]);

    _boid = Boid(position: Vector2(0, 0));
    world.add(_boid);
  }
}
