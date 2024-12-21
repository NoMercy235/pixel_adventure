import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/utils/constants.dart';

bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}

mixin HasFlameAudio on FlameGame {
  bool playSounds = true;
  double soundVolume = Constants.initialSoundVolume.value;

  playFlameSound(String path) {
    if (!playSounds) return;
    FlameAudio.play(path, volume: soundVolume);
  }
}
