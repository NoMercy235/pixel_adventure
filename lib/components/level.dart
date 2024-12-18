import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/utils/constants.dart';

class Level extends World {

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  final String levelName;
  final Player player;
  Level({ required this.levelName, required this.player });

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);

    for (final spawnPoint in _getLayer(PATileLayer.spawnpoints.name)) {
      if (spawnPoint.class_ == PASpawnPointName.player.name) {
        player.position = spawnPoint.position;
        add(player);
      }
    }

    for (final collision in _getLayer(PATileLayer.collisions.name)) {
      final switchRule = {
        PACollisionType.platform.name: () => _handleCollisionPlatform(collision),
        PACollisionType.object.name: () => _handleCollisionDefault(collision),
        PACollisionType.ground.name: () => _handleCollisionDefault(collision),
      }[collision.class_];
      switchRule?.call();
    }

    player.collisionBlocks = collisionBlocks;

    return super.onLoad();
  }

  List<TiledObject> _getLayer(String name) {
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
}