part of client;

class TerrainRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  SpriteSheet spriteSheet;
  ComponentMapper<TerrainTile> tm;
  TerrainRenderingSystem(this.ctx, this.spriteSheet) : super(Aspect.getAspectForAllOf([TerrainTile]));

  void initialize() {
    tm = new ComponentMapper<TerrainTile>(TerrainTile, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var sprite = spriteSheet['${t.spriteName}.png'];
    ctx.save();
    ctx.translate(t.x * GRID_SIZE, t.y* GRID_SIZE );
    ctx.drawImageToRect(spriteSheet.image, sprite.dst, sourceRect: sprite.src);
    ctx.restore();
  }
}

class SpriteRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  SpriteSheet spriteSheet;
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;
  SpriteRenderingSystem(this.ctx, this.spriteSheet) : super(Aspect.getAspectForAllOf([Renderable, Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    rm = new ComponentMapper<Renderable>(Renderable, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var r = rm.get(entity);
    var sprite = spriteSheet['${r.spriteName}.png'];
    ctx.save();
    ctx.translate(t.x * GRID_SIZE, t.y* GRID_SIZE );
    ctx.drawImageToRect(spriteSheet.image, sprite.dst, sourceRect: sprite.src);
    ctx.restore();
  }
}

class StateRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  int width, height;
  CanvasQuery stateCq;
  ComponentMapper<State> sm;
  double hungerWidth, cariesWidth, loosenessWidth;

  StateRenderingSystem(CanvasElement canvas) : ctx = canvas.context2D,
                                               width = canvas.width,
                                               height = canvas.height,
                                               super(Aspect.getAspectForAllOf([State]));


  void initialize() {
    sm = new ComponentMapper<State>(State, world);

    stateCq = cq(width, height);
    stateCq.context2D..font = '18px Verdana'
                     ..textBaseline = 'top'
                     ..fillStyle = 'green'
                     ..strokeStyle = 'black';

    hungerWidth = stateCq.measureText('Hunger: ').width;
    loosenessWidth = stateCq.measureText('Looseness: ').width;
    cariesWidth = stateCq.measureText('Caries: ').width;
    stateCq..strokeText('Hunger:', width - 100 - hungerWidth, 0)
           ..fillText('Hunger:', width - 100 - hungerWidth, 0)
           ..strokeText('Looseness:', width - 100 - loosenessWidth, 25)
           ..fillText('Looseness:', width - 100 - loosenessWidth, 25)
           ..strokeText('Caries:', width - 100 - cariesWidth, 50)
           ..fillText('Caries:', width - 100 - cariesWidth, 50)
           ..strokeRect(width - 100, 0, 100, 20)
           ..strokeRect(width - 100, 25, 100, 20)
           ..strokeRect(width - 100, 50, 100, 20);
  }

  void processEntity(Entity entity) {
    var s = sm.get(entity);

    ctx.drawImage(stateCq.canvas, 0, 0);
    ctx.setFillColorRgb(50 + s.hunger.toInt() * 2, 200 - s.hunger.toInt() * 2, 0);
    ctx.fillRect(width - 100, 0, s.hunger, 20);
    ctx.setFillColorRgb(50 + s.looseness.toInt() * 2, 200 - s.looseness.toInt() * 2, 0);
    ctx.fillRect(width - 100, 25, s.looseness, 20);
    ctx.setFillColorRgb(50 + s.caries.toInt() * 2, 200 - s.caries.toInt() * 2, 0);
    ctx.fillRect(width - 100, 50, s.caries, 20);
  }
}

class StartScreenRenderingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  CanvasQuery startScreen;
  Rectangle startButtonPos;
  int width, height;
  String startButtonText = '''I'll protect your tooth, granny!!!''';
  Rectangle<int> buttonBounds;
  bool highlightButton = false;
  StartScreenRenderingSystem(CanvasElement canvas) : canvas = canvas,
                                                     ctx = canvas.context2D,
                                                     width = canvas.width,
                                                     height = canvas.height {
  }

  void initialize() {
    if (state.startScreen == false) {
      world.deleteSystem(this);
      return;
    }

    startScreen = cq(canvas.width, canvas.height);
    initContext(startScreen.context2D);
    var paragraph1 = '''It's Christmas time and you have been wishing
for one special present for a long long time. Your only Grandma has promised 
that you'll get what you wished for. But lately, her only tooth has started
to getting loose.''';
    var paragraph2 = '''It's so bad, you have started to worry that she might lose it.
And in the worst case, she might be too sad to celebrate Christmas and you may
not get your present.''';
    var paragraph3 = '''That's why you have decided to make sure she won't lose
her only tooth. You do so by getting her regular appointments at the dentist and
most importantly prevent her from meeting any tooth fairy that might want to get
her hands on such an old and precious tooth.''';

    int textWidth = canvas.width - 140;
    int p1Height = startScreen.textBoundaries(paragraph1, textWidth).height;
    int p2Height = startScreen.textBoundaries(paragraph2, textWidth).height;
    startScreen..fillStyle = '#00BBBB'
               ..fillRect(0, 0, canvas.width, canvas.height)
               ..globalAlpha = 0.9
               ..lineWidth = 3
               ..roundRect(50, 50, canvas.width - 100, canvas.height - 100, 20, strokeStyle: 'black', fillStyle: '#224488')
               ..globalAlpha = 1.0
               ..fillStyle = '#00BBFF'
               ..wrappedText(paragraph1, 70, 70, canvas.width - 140)
               ..wrappedText(paragraph2, 70, 70 + p1Height + 10, canvas.width - 140)
               ..wrappedText(paragraph3, 70, 70 + p1Height + 10 + p2Height + 10, canvas.width - 140);
    buttonBounds = startScreen.textBoundaries(startButtonText);
    startButtonPos = new Rectangle((width - buttonBounds.width) ~/ 2 - 10, height - buttonBounds.height - 100 - 10, buttonBounds.width + 20, buttonBounds.height + 20);

    CanvasQuery hiddenButton = cq(width, height);
    hiddenButton.roundRect(startButtonPos.left, startButtonPos.top, startButtonPos.width, startButtonPos.height, 15, fillStyle: '#010000');

    var mouseMoveSubscription;
    var mouseClickSubscription;
    mouseMoveSubscription = canvas.onMouseMove.listen((event) {
      var data = hiddenButton.getImageData(event.offset.x, event.offset.y, 1, 1).data;
      if (data[0] == 1) {
        highlightButton = true;
      } else {
        highlightButton = false;
      }
    });
    mouseClickSubscription = canvas.onClick.listen((_) {
      if (highlightButton) {
        mouseClickSubscription.cancel();
        mouseMoveSubscription.cancel();
        world.deleteSystem(this);
        state.startScreen = false;
      }
    });
  }

  void processSystem() {
    startScreen..globalAlpha = 0.8
               ..roundRect(startButtonPos.left, startButtonPos.top, startButtonPos.width, startButtonPos.height, 15, strokeStyle: 'black', fillStyle: highlightButton ? '#000088' : '#000044')
               ..globalAlpha = 1.0
               ..fillText(startButtonText, (width - buttonBounds.width) ~/ 2, height - buttonBounds.height - 100);
    ctx.drawImage(startScreen.canvas, 0, 0);
  }
}

class ButtonRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  CanvasQuery buttonCanvas;
  int width, height;
  String startText = 'Go, Granny, go!';
  Button startButton, restartButton, nextLevelButton;
  ButtonRenderingSystem(CanvasElement canvas) : ctx = canvas.context2D,
                                                width = canvas.width,
                                                height = canvas.height;

  void initialize() {
    buttonCanvas = cq(width, height);
    initContext(buttonCanvas.context2D);
    startButton = new Button(startText, 50, 50, buttonCanvas.textBoundaries(startText));
    restartButton = new Button('Restart Level', 50, 100, buttonCanvas.textBoundaries('Restart Level'));
    nextLevelButton = new Button('Next Level', 50, 150, buttonCanvas.textBoundaries('Next Level'));
  }

  void processSystem() {
    drawButton(startButton);
    drawButton(restartButton);
    drawButton(nextLevelButton);
    ctx.drawImage(buttonCanvas.canvas, 0, 0);
  }

  void drawButton(Button button) {
    buttonCanvas..roundRect(button.pos.left, button.pos.top, button.pos.width, button.pos.height, button.radius, strokeStyle: 'black', fillStyle: button.color)
                ..fillStyle = button.textColor
                ..fillText(button.label, button.textPos.left, button.textPos.top);
  }
}

class Button {
  String label;
  String defaultColor, highlightColor;
  String textColor;
  Rectangle pos;
  Rectangle textPos;
  bool highlight = false;
  int radius = 15;
  Button(this.label, int x, int y, Rectangle<int> textBounds, {this.textColor: '#8090C0', this.defaultColor: '#DDDDDD', this.highlightColor: '#EEEEEE'}) {
    textPos = new Rectangle(x, y, textBounds.width, textBounds.height);
    pos = new Rectangle(textPos.left - 5, textPos.top - 5, textPos.width + 10, textPos.height + 10);
  }
  Button.dummy();
  String get color => highlight ?  highlightColor : defaultColor;
}