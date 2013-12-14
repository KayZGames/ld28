part of shared;

class TerrainMap implements Graph<TerrainTile> {
  List<TerrainTile> map;
  TerrainMap(this.map);

  Iterable<TerrainTile> get allNodes => map;
  num getDistance(TerrainTile a, TerrainTile b) => b.cost;
  num getHeuristicDistance(TerrainTile a, TerrainTile b) => max(a.x - b.x, a.y - b.y);
  Iterable<TerrainTile> getNeighboursOf(TerrainTile node) {
    var result = [];
    if (node.y > 0) {
      result.add(map[(node.y-1) * MAX_WIDTH + node.x]);
    }
    if (node.x % MAX_WIDTH > 0) {
      result.add(map[node.y * MAX_WIDTH + node.x - 1]);
    }
    if (node.x % MAX_WIDTH < MAX_WIDTH - 1) {
      result.add(map[node.y * MAX_WIDTH + node.x + 1]);
    }
    if (node.y < MAX_HEIGHT - 1) {
      result.add(map[(node.y+1) * MAX_WIDTH + node.x]);
    }
    return result;
  }
}