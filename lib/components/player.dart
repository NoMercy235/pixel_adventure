import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';
import 'package:pixel_adventure/utils/utils.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
}

const playerMoveSpeed = 100.0;
const animationPlayTime = 0.05;
const gravity = 9.8;
const jumpForce = 280.0;
const terminalVelocity = 300.0;
Vector2 velocity = Vector2.zero();

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  
  double horizontalMovement = 0.0;
  List<CollisionBlock> collisionBlocks = [];
  bool isOnGround = false;
  bool hasJumped = false;
  PlayerHitbox hitbox = PlayerHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  String character;

  Player({ required this.character, position }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    if (Constants.isDebugMode.value) {
      print('here');
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
    _updatePlayerMovement(dt);
    _updatePlayerState(dt);
    _checkHorizontalCollisions();
    _checkGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }
  
  void _loadAllAnimations() {
    idleAnimation = _getSpriteAnimationImages(PAAnimationType.idle.name, 11);
    runAnimation = _getSpriteAnimationImages(PAAnimationType.run.name, 12);
    jumpAnimation = _getSpriteAnimationImages(PAAnimationType.jump.name, 1);
    fallAnimation = _getSpriteAnimationImages(PAAnimationType.fall.name, 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: runAnimation,
      PlayerState.falling: runAnimation,
    };

    current = PlayerState.running;
  }

  SpriteAnimation _getSpriteAnimationImages(String animationName, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$animationName (32x32).png'), 
      SpriteAnimationData.sequenced(amount: amount, stepTime: animationPlayTime, textureSize: Vector2.all(32)),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    velocity.x = horizontalMovement * playerMoveSpeed;
    position.x += velocity.x * dt;
  }
  
  void _updatePlayerState(double dt) {
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
}