part of shared;

class PathfindingSystem extends IntervalEntityProcessingSystem {
  TerrainMap map;
  Queue<TerrainTile> path;
  ComponentMapper<Transform> tm;

  PathfindingSystem(this.map) : super(200, Aspect.getAspectForAllOf([Transform, PathFinder]).exclude([Eating]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
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
    }
  }
}