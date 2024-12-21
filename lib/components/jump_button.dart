import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

final margin = 32;
final buttonSize = 64;

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton();

  @override
  FutureOr<void> onLoad() {
    priority = PADisplayPriority.mobileControls.value;
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));

    final offset = margin + buttonSize;
    position = Vector2(
      Constants.worldWidth.value - offset,
      Constants.worldHeight.value - offset,
    );

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
