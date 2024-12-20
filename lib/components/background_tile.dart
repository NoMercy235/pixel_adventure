import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  final double scrollSpeed = Constants.scrollSpeed.value;

  BackgroundTile({ position, required this.color }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    // Showing this tile behind everything else on the screen
    priority = -1;

    // The tiles are pixel perfect, and having the size exactly at normalTileSize would cause the tiles to be divided by 1px lines
    // To fix this, we add a buffer which makes the tiles slightly bigger so they overlap and the lines disappear
    final buffer = 0.6; 
    size = Vector2.all((Constants.normalTileSize.value as double) + buffer);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    final tileSize = Constants.normalTileSize.value;
    final scrollHeight = (game.size.y / tileSize).floor();

    if (position.y > scrollHeight * tileSize) {
      // Moving the tile outside the screen boundaries so that the player does not notice it
      position.y = -tileSize;
    }

    super.update(dt);
  }
}