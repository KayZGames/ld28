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

const String GROUP_FOOD = 'food';

Random random = new Random();

int indexInGrid(int x, int y) => x + y * MAX_WIDTH;

GameState state = new GameState();

class GameState {
  bool startScreen = true;
  bool grannyWaiting = true;
  bool lost = false;
  int level = 0;
  void restartLevel() {
    startScreen = false;
    grannyWaiting = true;
    lost = false;
  }
}