library ld28.dart;

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  Game() : super.noAssets('ld28', 'canvas', 800, 600);


  void createEntities() {
    addEntity([new Transform(0, 0)]);
  }

  List<EntitySystem> getSystems() {
    return [
            new CanvasCleaningSystem(canvas),
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