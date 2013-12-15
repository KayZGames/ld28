part of client;

class LevelLoadingSystem extends VoidEntitySystem {
  bool loadLevel = true;
  MouseMovementListeningSystem mouseListening;
  FoodDispenserSystem dispenserSystem;
  PathfindingSystem pathfindingSystem;
  FoodDigestionSystem digestSystem;

  void initialize() {
    mouseListening = world.getSystem(MouseMovementListeningSystem);
    dispenserSystem = world.getSystem(FoodDispenserSystem);
    pathfindingSystem = world.getSystem(PathfindingSystem);
    digestSystem = world.getSystem(FoodDigestionSystem);
  }

  void processSystem() {
    world.deleteAllEntities();
    List<TerrainTile> map = [];
    TerrainTile startNode;
    TerrainTile goalNode;
    TerrainMap terrainMap;
    HttpRequest.getString('assets/ld28/levels/0${state.level}.txt').then((content) {
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
      addEntity([new Transform(startNode.x, startNode.y), new PathFinder(), new Renderable('player_'), new Directed(), new State(), new Waiting()]);
      addEntity([new Transform(0, 0), new Mouse(), new Renderable('cursor')]);
      map.where((tile) => null != tile).forEach((tile) {
        addEntity([tile]);
      });
      mouseListening.map = terrainMap;
      dispenserSystem.map = terrainMap;
      pathfindingSystem.map = terrainMap;
      pathfindingSystem.path = null;
      digestSystem.map = terrainMap;
      digestSystem.initFoodMap();
      state.restartLevel();
    });
    loadLevel = false;
  }

  Entity addEntity(List<Component> components) {
    var entity = world.createEntity();
    components.forEach((component) => entity.addComponent(component));
    entity.addToWorld();
    return entity;
  }

  bool checkProcessing() => loadLevel;
}