library shared;

import 'dart:math';

import 'package:dartemis/dartemis.dart';
export 'package:dartemis/dartemis.dart';
import 'package:a_star/a_star.dart';
export 'package:a_star/a_star.dart';

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'src/shared/components.dart';
part 'src/shared/map.dart';
//part 'src/shared/systems/name.dart';

const int GRID_SIZE = 10;
const int MAX_WIDTH = 80;
const int MAX_HEIGHT = 60;

Random random = new Random();