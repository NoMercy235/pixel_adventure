import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/constants.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  List<TiledObject> _getLayerObjects(String name) {
    return level.tileMap.getLayer<ObjectGroup>(name)?.objects ?? [];
  }

  void _handleCollisionPlatform(TiledObject collision) {
    final platform = CollisionBlock(
      isPlatform: true,
      position: Vector2(collision.x, collision.y),
      size: Vector2(collision.width, collision.height),
      isDebugMode: Constants.isDebugMode.value,
    );
    collisionBlocks.add(platform);
    add(platform);
  }

  void _handleCollisionDefault(TiledObject collision) {
    final block = CollisionBlock(
      position: Vector2(collision.x, collision.y),
      size: Vector2(collision.width, collision.height),
      isDebugMode: Constants.isDebugMode.value,
    );
    collisionBlocks.add(block);
    add(block);
  }

  void _scrollingBackground() {
    final bgLayer = level.tileMap.getLayer(PATileLayer.background.name);
    if (bgLayer == null) return;

    final tileSize = Constants.normalTileSize.value;
    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    for (double y = 0; y < game.size.y / numTilesY; y++) {
      for (double x = 0; x < numTilesX; x++) {
        final bgColor =
            bgLayer.properties.getValue(PAProperty.backgroundColor.name);
        final bgTile = BackgroundTile(
          color: bgColor ?? PAColors.gray,
          position: Vector2(x * tileSize, y * tileSize - tileSize),
        );

        add(bgTile);
      }
    }
  }

  void _spawningObjects() {
    for (final spawnPoint in _getLayerObjects(PATileLayer.spawnpoints.name)) {
      if (spawnPoint.class_ == PASpawnPointName.player.name) {
        player.position = spawnPoint.position;
        add(player);
      } else if (spawnPoint.class_ == PASpawnPointName.fruit.name) {
        final fruit = Fruit(
          name: spawnPoint.name,
          position: spawnPoint.position,
          size: spawnPoint.size,
        );
        add(fruit);
      } else if (spawnPoint.class_ == PASpawnPointName.saw.name) {
        final isVertical =
            spawnPoint.properties.getValue(PAProperty.isVertical.name);
        final offNeg = spawnPoint.properties.getValue(PAProperty.offNeg.name);
        final offPos = spawnPoint.properties.getValue(PAProperty.offPos.name);
        final saw = Saw(
          position: spawnPoint.position,
          size: spawnPoint.size,
          isVertical: isVertical,
          offNeg: offNeg,
          offPos: offPos,
        );
        add(saw);
      }
    }
  }

  void _addCollisions() {
    for (final collision in _getLayerObjects(PATileLayer.collisions.name)) {
      final switchRule = {
        PACollisionType.platform.name: () =>
            _handleCollisionPlatform(collision),
        PACollisionType.object.name: () => _handleCollisionDefault(collision),
        PACollisionType.ground.name: () => _handleCollisionDefault(collision),
      }[collision.class_];
      switchRule?.call();
    }

    player.collisionBlocks = collisionBlocks;
  }
}
