import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

final double animationPlayTime = 0.05;

enum CheckpointAnimationType {
  noFlag("(No Flag)"),
  flagOut("(Flag Out) (64x64)"),
  flagIdle("(Flag Idle) (64x64)"),
  ;

  final String name;
  const CheckpointAnimationType(this.name);
}

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    debugMode = Constants.isDebugMode.value;

    add(RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive));

    animation = _getAnimation(CheckpointAnimationType.noFlag.name, 1);
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _handleReachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _handleReachedCheckpoint() {
    animation = _getAnimation(CheckpointAnimationType.flagOut.name, 26)
      ..loop = false;
    animationTicker?.onComplete = () {
      animation = _getAnimation(CheckpointAnimationType.flagIdle.name, 10);
    };
  }

  SpriteAnimation _getAnimation(String type, int spriteAmount) {
    final spritePath = 'Items/Checkpoints/Checkpoint/Checkpoint $type.png';
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(spritePath),
      SpriteAnimationData.sequenced(
          amount: spriteAmount,
          stepTime: animationPlayTime,
          textureSize: Vector2.all(Constants.normalTileSize.value)),
    );
  }
}
