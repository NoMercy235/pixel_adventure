import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/utils/constants.dart';

final double _scrollSpeed = Constants.scrollSpeed.value;

class BackgroundTile extends ParallaxComponent {
  final String color;

  BackgroundTile({position, required this.color}) : super(position: position);

  @override
  FutureOr<void> onLoad() async {
    priority = PADisplayPriority.background.value;

    size = Vector2.all((Constants.normalTileSize.value as double));
    parallax = await game.loadParallax(
      [
        ParallaxImageData('Background/$color.png'),
      ],
      baseVelocity: Vector2(0, -_scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );

    return super.onLoad();
  }
}
