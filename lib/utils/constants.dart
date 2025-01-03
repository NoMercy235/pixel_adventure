class NewConstants {
  static const hellYeah = '';
}

enum Constants {
  isDebugMode(false),
  showMobileControls(false),
  smallTileSize(16.0),
  normalTileSize(64.0),
  textureSize(32.0),
  spawningTextureSize(96.0),
  sawTextureSize(38.0),
  scrollSpeed(40.0),
  worldWidth(640.0),
  worldHeight(360.0),
  initialSoundVolume(1.0),
  timeTilNextLevel(3),
  gravity(9.8),
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
  hit("Hit"),
  appearing("Appearing"),
  disappearing("Disappearing"),
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
  saw("Saw"),
  checkpoint("Checkpoint"),
  chicken("Chicken"),
  ;

  final String name;
  const PASpawnPointName(this.name);
}

enum PAProperty {
  backgroundColor("BackgroundColor"),
  isVertical("isVertical"),
  offNeg("offNeg"),
  offPos("offPos"),
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
  traps(-7),
  collectibles(-5),
  mobileControls(10),
  ;

  final int value;
  const PADisplayPriority(this.value);
}
