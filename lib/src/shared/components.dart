part of shared;

class Transform extends Component {
  int x, y;
  Transform(this.x, this.y);
}

class TerrainTile extends Component with Node {
  int x, y;
  int cost;
  String sprite;
  TerrainTile(this.x, this.y, this.cost, this.sprite);
  String toString() => '$x:$y';
}