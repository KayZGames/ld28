library ld28.dart;

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  Game() : super.noAssets('ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT);


  void createEntities() {
    addEntity([new Transform(0, 0)]);
    addEntity([new TerrainTile(0, 0, 'green')]);
    addEntity([new TerrainTile(1, 0, 'blue')]);
    addEntity([new TerrainTile(0, 1, 'red')]);
    addEntity([new TerrainTile(1, 1, 'yellow')]);
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
            new TerrainRenderingSystem(ctx),
            new RenderingSystem(ctx),
            new FpsRenderingSystem(ctx)
    ];
  }

  void onInit() {
    // TODO: implement onInit
  }

  void onInitDone() {
    // TODO: implement onInitDone
  }
}