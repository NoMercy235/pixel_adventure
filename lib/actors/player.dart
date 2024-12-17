import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

enum PlayerState {
  idle,
  running,
}

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure> {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  
  final double stepTime = 0.05;

  String character;

  Player({ required this.character, position }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
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
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)),
    );
  }
}