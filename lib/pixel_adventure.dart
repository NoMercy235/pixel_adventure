import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';
import 'package:pixel_adventure/utils/constants.dart';

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final CameraComponent cam;

  @override
  final world = Level(levelName: PALevel.level01.name);

  @override
  FutureOr<void> onLoad() async {
    // This could take a long time if there are MANY images, but for now it's fine
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([
      cam,
      world,
    ]);

    return super.onLoad();
  }
}