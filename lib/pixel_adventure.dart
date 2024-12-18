import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/utils/constants.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final CameraComponent cam;
  late final JoystickComponent joystick;

  Player player = Player(character: PACharacter.ninjaFrog.name);
  bool showJoystick = false;

  @override
  FutureOr<void> onLoad() async {
    // This could take a long time if there are MANY images, but for now it's fine
    await images.loadAllImages();

    final world = Level(
      levelName: PALevel.level01.name,
      player: player
    );

    cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    if (showJoystick) {
      joystick = _createJoyStick();
      cam.viewport.add(joystick);
    }

    addAll([
      cam,
      world,
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      _updateJoyStick();
    }
    super.update(dt);
  }

  JoystickComponent _createJoyStick() {
    return JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
  }
  
  void _updateJoyStick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }
}