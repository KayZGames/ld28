library shared;

import 'dart:math';
export 'dart:math';
import 'dart:collection';
export 'dart:collection';

import 'package:dartemis/dartemis.dart';
export 'package:dartemis/dartemis.dart';
import 'package:a_star/a_star.dart';
export 'package:a_star/a_star.dart';

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'src/shared/components.dart';
part 'src/shared/map.dart';

part 'src/shared/systems/logic.dart';
part 'src/shared/systems/pathfinding.dart';
//part 'src/shared/systems/name.dart';

const int GRID_SIZE = 20;
const int MAX_WIDTH = 40;
const int MAX_HEIGHT = 30;

Random random = new Random();

int indexInGrid(int x, int y) => x + y * MAX_WIDTH;

GameState state = new GameState();

class GameState {
  bool startScreen = true;
  bool grannyWaiting = true;
  bool lost = false;
  bool won = false;
  int level = 0;
  int maxLevel = 4;
  String selectedFood = 'carrot';
  void restartLevel() {
    grannyWaiting = true;
    lost = false;
    won = false;
  }
}

var foodTypes = { 'carrot': new FoodInfo('carrot', 20.0, 40.0, -10.0, 3000.0),
                  'cookies': new FoodInfo('cookies', 40.0, 20.0, 30.0, 1000.0),
                  'chips': new FoodInfo('chips', 10.0, 5.0, 15.0, 1000.0)
};

class FoodInfo {
  double filling, hardness, sweetness;
  double timeToEat;
  String spriteName;
  FoodInfo(this.spriteName, this.filling, this.hardness, this.sweetness, this.timeToEat);
}