import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

final double animationPlayTime = 0.05;

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String name;
  Fruit({super.position, super.size, required this.name});

  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);

  bool _collected = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = Constants.isDebugMode.value;
    priority = PADisplayPriority.collectibles.value;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$name.png'),
      SpriteAnimationData.sequenced(
          amount: 17,
          stepTime: animationPlayTime,
          textureSize: Vector2.all(Constants.textureSize.value)),
    );
    return super.onLoad();
  }

  void handlePlayerCollision() {
    if (_collected) return;
    _collected = true;

    game.playFlameSound('collect_fruit.wav');

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/Collected.png'),
      SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: animationPlayTime,
          textureSize: Vector2.all(Constants.textureSize.value),
          loop: false),
    );

    animationTicker?.onComplete = () => removeFromParent();
  }
}
