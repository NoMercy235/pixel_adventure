import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

final double animationPlayTime = 0.03;
final double moveSpeed = 50;
final double tileSize = Constants.smallTileSize.value;

enum RangeCheckResult {
  negative,
  inside,
  positive,
  ;
}

class Saw extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final bool isVertical;
  final double offNeg;
  final double offPos;
  Saw({
    super.position,
    super.size,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
  });

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = PADisplayPriority.traps.value;
    debugMode = Constants.isDebugMode.value;
    add(CircleHitbox());

    _calculateMovementRanges();

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: animationPlayTime,
          textureSize: Vector2.all(Constants.sawTextureSize.value)),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    isVertical ? _moveVertically(dt) : _moveHorizontally(dt);
    super.update(dt);
  }

  void handlePlayerCollision() {}

  void _calculateMovementRanges() {
    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }
  }

  void _moveVertically(double dt) {
    switch (_checkRange(position.y)) {
      case RangeCheckResult.positive:
        moveDirection = -1;
        break;
      case RangeCheckResult.negative:
        moveDirection = 1;
        break;
      default:
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    switch (_checkRange(position.x)) {
      case RangeCheckResult.positive:
        moveDirection = -1;
        break;
      case RangeCheckResult.negative:
        moveDirection = 1;
        break;
      default:
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  RangeCheckResult _checkRange(double pos) {
    if (pos >= rangePos) {
      return RangeCheckResult.positive;
    } else if (pos <= rangeNeg) {
      return RangeCheckResult.negative;
    }
    return RangeCheckResult.inside;
  }
}
