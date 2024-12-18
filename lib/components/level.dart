import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/utils/constants.dart';

class Level extends World {

  late TiledComponent level;

  final String levelName;
  final Player player;
  Level({ required this.levelName, required this.player });

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);

    for (final spawnPoint in getLayer(PATileLayer.spawnpoints.name)) {
      if (spawnPoint.class_ == PASpawnPointName.player.name) {
        player.position = spawnPoint.position;
        add(player);
      }
    }

    return super.onLoad();
  }

  List<TiledObject> getLayer(String name) {
    return level.tileMap.getLayer<ObjectGroup>(name)?.objects ?? [];
  }
}