import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

enum PlayerState {
  idle,
  running,
}

// enum PlayerDirection {
//   left,
//   right,
//   none
// }

const playerMoveSpeed = 100.0;
const animationPlayTime = 0.05;
Vector2 velocity = Vector2.zero();

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  
  // PlayerDirection playerDirection = PlayerDirection.none;
  // bool isFacingRight = true;
  double horizontalMovement = 0.0;

  String character;

  Player({ required this.character, position }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    _updatePlayerState(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }
  
  void _loadAllAnimations() {
    idleAnimation = _getSpriteAnimationImages(PAAnimationType.idle.name, 11);
    runAnimation = _getSpriteAnimationImages(PAAnimationType.run.name, 12);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
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
    velocity.x = horizontalMovement * playerMoveSpeed;
    position.x += velocity.s * dt;
  }
  
  void _updatePlayerState(double dt) {
    PlayerState ps = PlayerState.idle;

    if (velocity.x != 0) {
      if (velocity.x < 0 && scale.x > 0) {
        flipHorizontallyAroundCenter();
      } else if (velocity.x > 0 && scale.x < 0) {
        flipHorizontallyAroundCenter();
      }
      ps = PlayerState.running;
    }

    current = ps;
  }
}