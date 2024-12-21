import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';
import 'package:pixel_adventure/utils/utils.dart';

const _animationPlayTime = 0.05;
const _chickenMoveSpeed = 70.0;

enum ChickenState {
  idle,
  running,
  hit,
  disappearing,
}

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks, HasEnemyProperties {
  final double offNeg;
  final double offPos;
  Chicken({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _disappearingAnimation;
  late final Player player;

  double _rangeNeg = 0;
  double _rangePos = 0;
  Vector2 velocity = Vector2.zero();
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotKilled = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = Constants.isDebugMode.value;
    player = game.player;

    add(RectangleHitbox(
      position: Vector2(4, 6),
      size: Vector2(24, 26),
    ));

    _loadAllAnimations();
    _calculateRange();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotKilled) {
      _handleMovement(dt);
      _updateState();
    }
    super.update(dt);
  }

  void handlePlayerCollision() {
    // If player is falling
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      game.player.handleEnemyKill();
      game.playFlameSound('bounce.wav');
      gotKilled = true;
      current = ChickenState.hit;

      final hitAnimationTicker = animationTickers![ChickenState.hit]!;
      hitAnimationTicker.onComplete = () {
        removeFromParent();
      };
    } else {
      player.handleEnemyCollision(this);
    }
  }

  void _loadAllAnimations() {
    _idleAnimation = _getSpriteAnimationImages(PAAnimationType.idle.name, 13);
    _runAnimation = _getSpriteAnimationImages(PAAnimationType.run.name, 14);
    _hitAnimation = _getSpriteAnimationImages(PAAnimationType.hit.name, 5)
      ..loop = false;

    animations = {
      ChickenState.idle: _idleAnimation,
      ChickenState.running: _runAnimation,
      ChickenState.hit: _hitAnimation,
      // ChickenState.disappearing: disappearingAnimation,
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _getSpriteAnimationImages(String animationName, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Chicken/$animationName (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: _animationPlayTime,
        textureSize: Vector2(32, 34),
      ),
    );
  }

  void _calculateRange() {
    _rangeNeg = position.x - offNeg * Constants.smallTileSize.value;
    _rangePos = position.x + offPos * Constants.smallTileSize.value;
  }

  void _handleMovement(double dt) {
    velocity.x = 0;

    double playerOffset = player.scale.x > 0 ? 0 : -player.width;
    double chickenOffset = scale.x > 0 ? 0 : -width;
    if (_playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * _chickenMoveSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool _playerInRange() {
    double playerOffset = player.scale.x > 0 ? 0 : -player.width;

    return player.x + playerOffset >= _rangeNeg &&
        player.x + playerOffset <= _rangePos &&
        player.y + height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? ChickenState.running : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }
}
