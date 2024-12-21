import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';
import 'package:pixel_adventure/utils/utils.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing,
}

const playerMoveSpeed = 100.0;
const animationPlayTime = 0.05;
const gravity = 9.8;
const jumpForce = 280.0;
const terminalVelocity = 300.0;
Vector2 velocity = Vector2.zero();

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  double horizontalMovement = 0.0;
  List<CollisionBlock> collisionBlocks = [];
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool hasReachedCheckpoint = false;
  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  Vector2 startingPosition = Vector2(0, 0);
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  String character;

  Player({super.position, required this.character});

  @override
  FutureOr<void> onLoad() {
    startingPosition = Vector2(position.x, position.y);
    _loadAllAnimations();

    if (Constants.isDebugMode.value) {
      debugMode = true;
      add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ));
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !hasReachedCheckpoint) {
        _updatePlayerMovement(fixedDeltaTime);
        _updatePlayerState();
        _checkHorizontalCollisions();
        _checkGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= dt;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!hasReachedCheckpoint) {
      if (other is Fruit) other.handlePlayerCollision();
      if (other is Saw && !gotHit) _respawn();
      if (other is Checkpoint) _handleReachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation =
        _getCharacterSpriteAnimationImages(PAAnimationType.idle.name, 11);
    runAnimation =
        _getCharacterSpriteAnimationImages(PAAnimationType.run.name, 12);
    jumpAnimation =
        _getCharacterSpriteAnimationImages(PAAnimationType.jump.name, 1);
    fallAnimation =
        _getCharacterSpriteAnimationImages(PAAnimationType.fall.name, 1);
    hitAnimation =
        _getCharacterSpriteAnimationImages(PAAnimationType.hit.name, 7)
          ..loop = false;
    appearingAnimation =
        _getSpawningSpriteAnimationImages(PAAnimationType.appearing.name, 7)
          ..loop = false;
    disappearingAnimation =
        _getSpawningSpriteAnimationImages(PAAnimationType.disappearing.name, 7)
          ..loop = false;

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpAnimation,
      PlayerState.falling: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _getCharacterSpriteAnimationImages(
      String animationName, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Main Characters/$character/$animationName (32x32).png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: animationPlayTime,
          textureSize: Vector2.all(Constants.textureSize.value)),
    );
  }

  SpriteAnimation _getSpawningSpriteAnimationImages(
      String animationName, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$animationName (96x96).png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: animationPlayTime,
          textureSize: Vector2.all(Constants.spawningTextureSize.value)),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    velocity.x = horizontalMovement * playerMoveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState ps = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) ps = PlayerState.running;
    if (velocity.y > gravity) ps = PlayerState.falling;
    if (velocity.y < 0) ps = PlayerState.jumping;

    current = ps;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        continue;
      }
      if (checkCollision(this, block)) {
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitbox.offsetX - hitbox.width;
          break;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          break;
        }
      }
    }
  }

  void _checkGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            continue;
          }
        }
        continue;
      }

      if (checkCollision(this, block)) {
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.offsetY;
          isOnGround = true;
          continue;
        }

        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = block.y + block.height - hitbox.offsetY;
        }
      }
    }
  }

  void _playerJump(double dt) {
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _respawn() {
    gotHit = true;

    current = PlayerState.hit;
    final hitAnimationTicker = animationTickers![PlayerState.hit]!;

    hitAnimationTicker.onComplete = () {
      scale.x = 1;
      // We need to offset the position of the appearing animation because it is bigger than
      // the player animation itself.
      final offsetPos = Constants.spawningTextureSize.value -
          (Constants.textureSize.value * 2);
      position = startingPosition - Vector2.all(offsetPos);
      current = PlayerState.appearing;
      hitAnimationTicker.reset();

      final appearingAnimationTicker =
          animationTickers![PlayerState.appearing]!;
      appearingAnimationTicker.onComplete = () {
        current = PlayerState.idle;
        position = startingPosition;
        velocity = Vector2.zero();
        gotHit = false;
        appearingAnimationTicker.reset();
      };
    };
  }

  void _handleReachedCheckpoint() {
    hasReachedCheckpoint = true;
    current = PlayerState.disappearing;

    // If facing to the right... or to the left
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    final disappearingAnimationTicker =
        animationTickers![PlayerState.disappearing]!;
    disappearingAnimationTicker.onComplete = () {
      // removeFromParent();
      disappearingAnimationTicker.reset();
      hasReachedCheckpoint = false;
      // hiding the player so the user does not see the leftover animation
      position = Vector2.all(-640);

      const waitTilNextLevel = Duration(seconds: 3);
      Future.delayed(waitTilNextLevel, () {
        game.loadNextLevel();
      });
    };
  }
}
