library ld28.dart;

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  List<TerrainTile> map = [];
  Game() : super.noAssets('ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT);


  void createEntities() {
    addEntity([new Transform(0, 0)]);
    map.forEach((tile) {
      addEntity([tile]);
    });
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
    for (int y = 0; y < MAX_HEIGHT; y++) {
      for (int x = 0; x < MAX_WIDTH; x++) {
        map.add(new TerrainTile(x, y, random.nextInt(10), 'green'));
      }
    }
  }

  void onInitDone() {
    var aStar = new AStar(new TerrainMap(map));
    var start = map[0];
    var goal = map[MAX_WIDTH * MAX_HEIGHT - 1];
    aStar.findPath(map[0], map[MAX_WIDTH * MAX_HEIGHT - 1])
         .then((path) {
           path.forEach((node) {
            addEntity([new Transform(node.x, node.y)]);
           });
         });
  }
}