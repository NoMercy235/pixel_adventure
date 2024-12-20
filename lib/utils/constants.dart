import 'dart:ffi';

enum Constants {
  isDebugMode(true),
  normalTileSize(64.0),
  textureSize(32.0),
  scrollSpeed(0.4),
  ;

  final dynamic value;
  const Constants(this.value);
}

enum PACharacter {
  maskDude("Mask Dude"),
  ninjaFrog("Ninja Frog"),
  pinkMan("Pink Man"),
  virtualGuy("Virtual Guy"),
  ;

  final String name;
  const PACharacter(this.name);
}

enum PAAnimationType {
  idle("Idle"),
  run("Run"),
  jump("Jump"),
  fall("Fall"),
  ;

  final String name;
  const PAAnimationType(this.name);
}

enum PATileLayer {
  spawnpoints("Spawnpoints"),
  collisions("Collisions"),
  background("Background"),
  ;

  final String name;
  const PATileLayer(this.name);
}

enum PASpawnPointName {
  player("Player"),
  fruit("Fruit"),
  ;

  final String name;
  const PASpawnPointName(this.name);
}

enum PAProperty {
  backgroundColor("BackgroundColor"),
  ;

  final String name;
  const PAProperty(this.name);
}

enum PALevel {
  level01("Level-01"),
  level02("Level-02"),
  ;

  final String name;
  const PALevel(this.name);
}

enum PACollisionType {
  platform("Platform"),
  object("Object"),
  ground("Ground"),
  ;

  final String name;
  const PACollisionType(this.name);
}

enum PAColors {
  gray("Gray"),
  ;

  final String name;
  const PAColors(this.name);
}

enum PAObjects {
  apple("Apple"),
  ;

  final String name;
  const PAObjects(this.name);
}

enum PADisplayPriority {
  background(-10),
  collectibles(-5),
  ;

  final int value;
  const PADisplayPriority(this.value);
}