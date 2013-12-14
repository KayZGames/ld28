library ld28.dart;

import 'dart:async';

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  var costs = {' ': 10,
               'S': 10,
               'E': 10,
               'F': 10,
               'C': -100};
  var sprites = {'_': 'void',
                 ' ': 'floor',
                 '#': 'wall',
                 'S': 'floor',
                 'F': 'floor',
                 'C': 'floor',
                 'E': 'floor'};
  List<TerrainTile> map = [];
  Queue<TerrainTile> path;
  TerrainTile startNode;
  TerrainTile goalNode;
  Game() : super('ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT, bodyDefsName: null);


  void createEntities() {
    addEntity([new Transform(startNode.x, startNode.y), new PathFinder(), new Renderable('player_'), new Directed(), new State()]);
    map.where((tile) => null != tile).forEach((tile) {
      addEntity([tile]);
    });
  }

  List<EntitySystem> getSystems() {
    return [
            new PathfindingSystem(new TerrainMap(map, goalNode)),
            new HungerSystem(),
            new FoodDigestionSystem(),
            new CanvasCleaningSystem(canvas),
            new TerrainRenderingSystem(ctx, spriteSheet),
            new SpriteDirectionSystem(),
            new SpriteRenderingSystem(ctx, spriteSheet),
            new StateRenderingSystem(canvas),
            new FpsRenderingSystem(ctx)
    ];
  }

  Future onInit() {
    var gm = new GroupManager();
    world.addManager(gm);
    return HttpRequest.getString('assets/ld28/levels/00.txt').then((content) {
      var tiles = content.split('');
      tiles.where((tile) => tile != '\n' && tile != '\r').forEach((tile) {
        var x = map.length % MAX_WIDTH;
        var y = map.length ~/ MAX_WIDTH;
        var tt = new TerrainTile(x, y, costs[tile], sprites[tile]);
        if (tile == 'S') {
          startNode = tt;
        } else if (tile == 'E') {
          goalNode = tt;
        }
        map.add(tt);
        if (tile == 'C') {
          var food = addEntity([new Transform(x, y), new Renderable('carrot'), new Food(filling: 20, hardness: 50, sweetness: 5)]);
          gm.add(food, GROUP_FOOD);
        } else if (tile == 'F') {
          addEntity([new Transform(x, y), new Renderable('fairy')]);
        }
      });
    });
  }

  Future onInitDone() {}
}