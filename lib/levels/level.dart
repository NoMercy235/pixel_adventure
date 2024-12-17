import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/utils/constants.dart';

class Level extends World {

  late TiledComponent level;

  final String levelName;
  Level({ required this.levelName });

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>(PATileLayer.spawnpoints.name);
    for (final spawnPoint in spawnPointsLayer!.objects) {
      if (spawnPoint.class_ == PASpawnPointName.player.name) {
        final player = Player(character: PACharacter.ninjaFrog.name, position: spawnPoint.position);
          add(player);
      }
    }

    return super.onLoad();
  }

}