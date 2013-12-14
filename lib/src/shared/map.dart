part of shared;

class TerrainMap implements Graph<TerrainTile> {
  List<TerrainTile> completeMap;
  List<TerrainTile> map;
  TerrainTile goal;
  TerrainMap(List<TerrainTile> completeMap, this.goal) : map = completeMap.where((tile) => null != tile).toList(growable: false),
                                                         completeMap = completeMap;

  Iterable<TerrainTile> get allNodes => map;
  num getDistance(TerrainTile a, TerrainTile b) => b.cost;
  num getHeuristicDistance(TerrainTile a, TerrainTile b) => max(a.x - b.x, a.y - b.y) * GRID_SIZE;
  Iterable<TerrainTile> getNeighboursOf(TerrainTile node) {
    var result = [];
    if (node.y > 0) {
      addNeighbour(result, (node.y-1) * MAX_WIDTH + node.x);
    }
    if (node.x % MAX_WIDTH > 0) {
      addNeighbour(result, node.y * MAX_WIDTH + node.x - 1);
    }
    if (node.x % MAX_WIDTH < MAX_WIDTH - 1) {
      addNeighbour(result, node.y * MAX_WIDTH + node.x + 1);
    }
    if (node.y < MAX_HEIGHT - 1) {
      addNeighbour(result, (node.y+1) * MAX_WIDTH + node.x);
    }
    return result;
  }

  void addNeighbour(result, index) {
    var neighbor = completeMap[index];
    if (null != neighbor) {
      result.add(neighbor);
    }
  }


}