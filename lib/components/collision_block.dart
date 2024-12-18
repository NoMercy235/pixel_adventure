import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  bool isDebugMode;

  CollisionBlock({ position, size, this.isPlatform = false, this.isDebugMode = false }) : super(position: position, size: size) {
    debugMode = isDebugMode;
  }
}