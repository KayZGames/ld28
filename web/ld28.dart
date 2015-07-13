library ld28.dart;

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  Game() : super(
          'ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT,
          bodyDefsName: null);

  void createEntities() {}

  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new MouseMovementListeningSystem(canvas),
        new FoodDispenserSystem(canvas),
        new CanvasCleaningSystem(canvas),
        new TerrainRenderingSystem(ctx, spriteSheet),
        new ButtonRenderingSystem(canvas),
        new SpriteRenderingSystem(ctx, spriteSheet),
        new StateRenderingSystem(canvas),
        new GameLostRenderingSystem(canvas),
        new LevelCompletedRenderingSystem(canvas),
        new GameWonRenderingSystem(canvas),
        new StartScreenRenderingSystem(canvas, spriteSheet),
        new GameStateModificationSystem(canvas),
        new SoundSystem(helper.audioHelper)
      ],
      GameBase.physics: [
        new PathfindingSystem(),
        new HungerSystem(),
        new FoodDigestionSystem(),
        new FairyEncounterSystem(),
        new StateObservationSystem(),
        new SpriteDirectionSystem(),
        new LevelLoadingSystem(),
      ]
    };
  }

  onInit() {
    return helper.audioHelper.loadAudioClips(['carrot', 'cookies', 'chips']);
  }

}
