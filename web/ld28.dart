library ld28.dart;

import 'dart:async';

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super('ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT, bodyDefsName: null);

  void createEntities() {}

  List<EntitySystem> getSystems() {
    return [
            new MouseMovementListeningSystem(canvas),
            new FoodDispenserSystem(canvas),
            new PathfindingSystem(),
            new HungerSystem(),
            new FoodDigestionSystem(),
            new FairyEncounterSystem(),
            new StateObservationSystem(),
            new CanvasCleaningSystem(canvas),
            new TerrainRenderingSystem(ctx, spriteSheet),
            new ButtonRenderingSystem(canvas),
            new SpriteDirectionSystem(),
            new SpriteRenderingSystem(ctx, spriteSheet),
            new StateRenderingSystem(canvas),
            new GameLostRenderingSystem(canvas),
            new LevelCompletedRenderingSystem(canvas),
            new GameWonRenderingSystem(canvas),
            new StartScreenRenderingSystem(canvas),
            new FpsRenderingSystem(ctx),
            new GameStateModificationSystem(canvas),
            new LevelLoadingSystem(),
    ];
  }

  Future onInit() {}

  Future onInitDone() {}
}