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
    addEntity([new Transform(startNode.x, startNode.y), new PathFinder(), new Renderable('player_'), new Directed()]);
    map.where((tile) => null != tile).forEach((tile) {
      addEntity([tile]);
    });
  }

  List<EntitySystem> getSystems() {
    return [
            new PathfindingSystem(new TerrainMap(map, goalNode)),
            new CanvasCleaningSystem(canvas),
            new TerrainRenderingSystem(ctx, spriteSheet),
            new SpriteDirectionSystem(),
            new SpriteRenderingSystem(ctx, spriteSheet),
            new FpsRenderingSystem(ctx)
    ];
  }

  Future onInit() {
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
          addEntity([new Transform(x, y), new Renderable('carrot')]);
        } else if (tile == 'F') {
          addEntity([new Transform(x, y), new Renderable('fairy')]);
        }
      });
    });
  }

  Future onInitDone() {}
}