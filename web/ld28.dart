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
               'C': 10};
  var sprites = {'_': 'white',
                 ' ': 'green',
                 '#': 'black',
                 'S': 'green',
                 'F': 'red',
                 'C': 'orange',
                 'E': 'red'};
  List<TerrainTile> map = [];
  Queue<TerrainTile> path;
  TerrainTile startNode;
  TerrainTile goalNode;
  Game() : super.noAssets('ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT);


  void createEntities() {
    addEntity([new Transform(startNode.x, startNode.y), new PathFinder()]);
    map.where((tile) => null != tile).forEach((tile) {
      addEntity([tile]);
    });
  }

  List<EntitySystem> getSystems() {
    return [
            new PathfindingSystem(new TerrainMap(map, goalNode)),
            new CanvasCleaningSystem(canvas),
            new TerrainRenderingSystem(ctx),
            new RenderingSystem(ctx),
            new FpsRenderingSystem(ctx)
    ];
  }

  Future onInit() {
    return HttpRequest.getString('assets/ld28/levels/00.txt').then((content) {
      var tiles = content.split('');
      tiles.forEach((tile) {
        var tt = new TerrainTile(map.length % MAX_WIDTH, map.length ~/ MAX_WIDTH, costs[tile], sprites[tile]);
        if (tile == 'S') {
          startNode = tt;
        } else if (tile == 'E') {
          goalNode = tt;
        }
        map.add(tt);
      });
    });
  }

  Future onInitDone() {}
}