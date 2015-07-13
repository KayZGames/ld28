part of shared;

class PathfindingSystem extends IntervalEntitySystem {
  TerrainMap map;
  Queue<TerrainTile> path;
  Mapper<Transform> tm;

  PathfindingSystem() : super(0.2, Aspect
          .getAspectForAllOf([Transform, PathFinder])
          .exclude([Eating, Waiting]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    entities.forEach((entity) {
      var t = tm[entity];
      if (path == null) {
        var aStar = new AStar(map);
        var startNode = map.completeMap[t.x + t.y * MAX_WIDTH];
        path = aStar.findPathSync(startNode, map.goal);
      }
      if (path.isNotEmpty) {
        var next = path.removeFirst();
        t.x = next.x;
        t.y = next.y;
      } else {
        entity.removeComponent(PathFinder);
        entity.addComponent(new Waiting());
        state.won = true;
        entity.changedInWorld();
      }
    });
  }
}
