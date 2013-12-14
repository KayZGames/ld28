part of shared;

class Transform extends Component {
  int _x, _y;
  String direction = 'right';
  Transform(this._x, this._y);
  void set x(int value) {
    if (value > x) {
      direction = 'right';
    } else if (value < x) {
      direction = 'left';
    }
    _x = value;
  }
  int get x => _x;
  void set y(int value) {
    if (value > y) {
      direction = 'down';
    } else if (value < y) {
      direction = 'up';
    }
    _y = value;
  }
  int get y => _y;
}

class TerrainTile extends Component with Node {
  int x, y;
  int cost;
  String spriteName;
  TerrainTile(this.x, this.y, this.cost, this.spriteName);
  String toString() => '$x:$y';
}

class PathFinder extends Component {}

class Renderable extends Component {
  String _spriteName;
  String subspriteName = '';
  Renderable(this._spriteName);
  String get spriteName => '$_spriteName$subspriteName';
}

class Directed extends Component {}

class Food extends Component {
  int filling, hardness, sweetness;
  Food({this.filling: 20, this.hardness: 20, this.sweetness: 20});
}

class State extends Component {
  int hunger = 0,
      looseness = 0,
      caries = 0;
  State();
}