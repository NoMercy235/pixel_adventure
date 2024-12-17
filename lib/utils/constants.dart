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
  run("Run");

  final String name;

  const PAAnimationType(this.name);
}

enum PATileLayer {
  spawnpoints("Spawnpoints");

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