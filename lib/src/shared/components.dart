part of shared;

class Transform extends Component {
  int x, y;
  Transform(this.x, this.y);
}

class TerrainTile extends Component {
  int x, y;
  String sprite;
  TerrainTile(this.x, this.y, this.sprite);
}