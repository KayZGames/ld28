library client;

import 'dart:html' hide Node;
export 'dart:html' hide Node;

import 'package:ld28/shared.dart';
export 'package:ld28/shared.dart';

import 'package:canvas_query/canvas_query.dart';
export 'package:canvas_query/canvas_query.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';

//part 'src/client/systems/name.dart';
part 'src/client/systems/eventlistening.dart';
part 'src/client/systems/levelloading.dart';
part 'src/client/systems/rendering.dart';


void initContext(CanvasRenderingContext2D ctx) {
  ctx..font = '18px Verdana'
     ..textBaseline = 'top'
     ..fillStyle = 'green'
     ..strokeStyle = 'black';
}

var tileInfo = {'_': new TileInfo(null, 'void', false, false),
                ' ': new TileInfo(10, 'floor', true, false),
                'S': new TileInfo(10, 'floor', true, false),
                '#': new TileInfo(null, 'wall', false, false),
                'F': new TileInfo(10, 'floor', true, true),
                'E': new TileInfo(10, 'floor', true, false)
};