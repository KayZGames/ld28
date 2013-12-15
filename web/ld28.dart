library ld28.dart;

import 'dart:async';

import 'package:ld28/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  var tileInfo = {'_': new TileInfo(null, 'void', false, false),
                  ' ': new TileInfo(10, 'floor', true, false),
                  'S': new TileInfo(10, 'floor', true, false),
                  '#': new TileInfo(null, 'wall', false, false),
                  'F': new TileInfo(10, 'floor', true, true),
                  'E': new TileInfo(10, 'floor', true, false)
  };

  List<TerrainTile> map = [];
  Queue<TerrainTile> path;
  TerrainTile startNode;
  TerrainTile goalNode;
  TerrainMap terrainMap;
  CanvasQuery startScreenCq;
  Game() : super('ld28', 'canvas', GRID_SIZE * MAX_WIDTH, GRID_SIZE * MAX_HEIGHT, bodyDefsName: null);


  void createEntities() {
    addEntity([new Transform(startNode.x, startNode.y), new PathFinder(), new Renderable('player_'), new Directed(), new State(), new Waiting()]);
    addEntity([new Transform(0, 0), new Mouse(), new Renderable('cursor')]);
    map.where((tile) => null != tile).forEach((tile) {
      addEntity([tile]);
    });
  }

  List<EntitySystem> getSystems() {
    return [
            new MouseMovementListeningSystem(canvas, terrainMap),
            new FoodDispenserSystem(canvas, terrainMap),
            new PathfindingSystem(new TerrainMap(map, goalNode)),
            new HungerSystem(),
            new FoodDigestionSystem(terrainMap),
            new CanvasCleaningSystem(canvas),
            new TerrainRenderingSystem(ctx, spriteSheet),
            new ButtonRenderingSystem(canvas),
            new SpriteDirectionSystem(),
            new SpriteRenderingSystem(ctx, spriteSheet),
            new StateRenderingSystem(canvas),
            new StartScreenRenderingSystem(canvas, startScreenCq),
            new FpsRenderingSystem(ctx),
            new GameStateModificationSystem(canvas),
    ];
  }

  Future onInit() {
    startScreenCq = cq(canvas.width, canvas.height);
    initContext(startScreenCq.context2D);
    var paragraph1 = '''It's Christmas time and you have been wishing
for one special present for a long long time. Your only Grandma has promised 
that you'll get what you wished for. But lately, her only tooth has started
to getting loose.''';
    var paragraph2 = '''It's so bad, you have started to worry that she might lose it.
And in the worst case, she might be too sad to celebrate Christmas and you may
not get your present.''';
    var paragraph3 = '''That's why you have decided to make sure she won't lose
her only tooth. You do so by getting her regular appointments at the dentist and
most importantly prevent her from meeting any tooth fairy that might want to get
her hands on such an old and precious tooth.''';

    int textWidth = canvas.width - 140;
    int p1Height = startScreenCq.textBoundaries(paragraph1, textWidth).height;
    int p2Height = startScreenCq.textBoundaries(paragraph2, textWidth).height;
    startScreenCq..fillStyle = '#00BBBB'
                 ..fillRect(0, 0, canvas.width, canvas.height)
                 ..globalAlpha = 0.9
                 ..lineWidth = 3
                 ..roundRect(50, 50, canvas.width - 100, canvas.height - 100, 20, strokeStyle: 'black', fillStyle: '#224488')
                 ..globalAlpha = 1.0
                 ..fillStyle = '#00BBFF'
                 ..wrappedText(paragraph1, 70, 70, canvas.width - 140)
                 ..wrappedText(paragraph2, 70, 70 + p1Height + 10, canvas.width - 140)
                 ..wrappedText(paragraph3, 70, 70 + p1Height + 10 + p2Height + 10, canvas.width - 140);

    CanvasQuery ingameButtonsCq = cq(canvas.width, canvas.height);
    initContext(ingameButtonsCq.context2D);

    return HttpRequest.getString('assets/ld28/levels/00.txt').then((content) {
      var tiles = content.split('');
      tiles.where((tile) => tile != '\n' && tile != '\r').forEach((tile) {
        var x = map.length % MAX_WIDTH;
        var y = map.length ~/ MAX_WIDTH;
        var tt = new TerrainTile(x, y, tileInfo[tile]);
        if (tile == 'S') {
          startNode = tt;
        } else if (tile == 'E') {
          goalNode = tt;
        }
        map.add(tt);
        if (tile == 'F') {
          addEntity([new Transform(x, y), new Renderable('fairy')]);
        }
      });
      terrainMap = new TerrainMap(map, goalNode);
    });
  }

  Future onInitDone() {}
}