import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/utils/constants.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  late final JoystickComponent joystick;
  late final JumpButton jumpButton;

  Player player = Player(character: PACharacter.maskDude.name);
  bool showMobileControls = Constants.showMobileControls.value;
  List<PALevel> levels = [PALevel.level01, PALevel.level01];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // This could take a long time if there are MANY images, but for now it's fine
    await images.loadAllImages();

    _loadLevel(levels[currentLevelIndex]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showMobileControls) {
      _updateJoyStick();
    }
    super.update(dt);
  }

  void loadNextLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      currentLevelIndex = currentLevelIndex < levels.length - 1
          ? currentLevelIndex + 1
          : currentLevelIndex;
      _loadLevel(levels[currentLevelIndex]);
    });
  }

  JoystickComponent _createJoyStick() {
    return JoystickComponent(
      priority: PADisplayPriority.mobileControls.value,
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

  void _loadLevel(PALevel level) {
    Level world = Level(levelName: level.name, player: player);

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: Constants.worldWidth.value,
      height: Constants.worldHeight.value,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    if (showMobileControls) {
      joystick = _createJoyStick();
      jumpButton = JumpButton();
      cam.viewport.addAll([joystick, jumpButton]);
    }

    addAll([
      cam,
      world,
    ]);
  }
}
