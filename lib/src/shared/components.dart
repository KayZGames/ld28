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
  bool occupied, occupiable;
  TerrainTile(this.x, this.y, TileInfo tileInfo) : cost = tileInfo.cost,
                                                   spriteName = tileInfo.sprite,
                                                   occupied = tileInfo.occupied,
                                                   occupiable = tileInfo.occupiable;
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
  double filling, hardness, sweetness;
  double timeToEat, timeLeftToEat;
  Food({this.filling: 20.0, this.hardness: 20.0, this.sweetness: 20.0, this.timeToEat: 1000.0}) {
    timeLeftToEat = timeToEat;
  }
}

class State extends Component {
  double hunger = 0.0,
         looseness = 0.0,
         caries = 0.0;
  State();
}

class Eating extends Component {}
class Mouse extends Component {}