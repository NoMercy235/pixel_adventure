enum Constants {
  isDebugMode(true);

  final dynamic value;

  const Constants(this.value);
}

enum PACharacter {
  maskDude("Mask Dude"),
  ninjaFrog("Ninja Frog"),
  pinkMan("Pink Man"),
  virtualGuy("Virtual Guy");

  final String name;

  const PACharacter(this.name);
}

enum PAAnimationType {
  idle("Idle"),
  run("Run"),
  jump("Jump"),
  fall("Fall");

  final String name;

  const PAAnimationType(this.name);
}

enum PATileLayer {
  spawnpoints("Spawnpoints"),
  collisions("Collisions");

  final String name;

  const PATileLayer(this.name);
}

enum PASpawnPointName {
  player("Player");

  final String name;

  const PASpawnPointName(this.name);
}

enum PALevel {
  level01("Level-01"),
  level02("Level-02");

  final String name;

  const PALevel(this.name);
}

enum PACollisionType {
  platform("Platform"),
  object("Object"),
  ground("Ground");

  final String name;

  const PACollisionType(this.name);
}