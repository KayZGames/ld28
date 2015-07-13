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

class Button {
  String label;
  String defaultColor, highlightColor, selectedColor;
  String textColor;
  Rectangle pos;
  Rectangle textPos;
  bool highlight = false, selected = false;
  ShowCondition showCondition = () => false;
  int radius = 15;
  Button(this.label, int x, int y, Rectangle<int> textBounds, this.showCondition, {this.textColor: '#8090C0', this.defaultColor: '#DDDDDD', this.highlightColor: '#EEEEEE', this.selectedColor: '#BBBBBB'}) {
    textPos = new Rectangle(x, y, textBounds.width, textBounds.height);
    pos = new Rectangle(textPos.left - 5, textPos.top - 5, textPos.width + 10, textPos.height + 10);
  }
  Button.dummy();
  String get color => selected ? selectedColor : highlight ?  highlightColor : defaultColor;
  bool get show => showCondition();
}

typedef bool ShowCondition();