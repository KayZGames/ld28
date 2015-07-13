part of client;

class TerrainRenderingSystem extends EntitySystem {
  CanvasRenderingContext2D ctx;
  SpriteSheet spriteSheet;
  Mapper<TerrainTile> tm;
  CanvasRenderingContext2D terrainBuffer;
  TerrainRenderingSystem(this.ctx, this.spriteSheet)
      : super(Aspect.getAspectForAllOf([TerrainTile]));

  void initialize() {
    tm = new Mapper<TerrainTile>(TerrainTile, world);
  }

  void processEntities(Iterable<Entity> entities) {
    if (null == terrainBuffer) {
      terrainBuffer = new CanvasElement(width: 800, height: 600).context2D;
      entities.forEach((entity) {
        var t = tm[entity];
        var sprite = spriteSheet['${t.spriteName}.png'];
        terrainBuffer
          ..save()
          ..translate(t.x * GRID_SIZE, t.y * GRID_SIZE)
          ..drawImageToRect(spriteSheet.image, sprite.dst,
              sourceRect: sprite.src)
          ..restore();
      });
    }
    ctx.drawImage(terrainBuffer.canvas, 0, 0);
  }

  bool checkProcessing() => true;
}

class SpriteRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  SpriteSheet spriteSheet;
  Mapper<Transform> tm;
  Mapper<Renderable> rm;
  SpriteRenderingSystem(this.ctx, this.spriteSheet)
      : super(Aspect.getAspectForAllOf([Renderable, Transform]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    rm = new Mapper<Renderable>(Renderable, world);
  }

  void processEntity(Entity entity) {
    var t = tm[entity];
    var r = rm[entity];
    var sprite = spriteSheet['${r.spriteName}.png'];
    ctx.save();
    ctx.translate(t.x * GRID_SIZE, t.y * GRID_SIZE);
    ctx.drawImageToRect(spriteSheet.image, sprite.dst, sourceRect: sprite.src);
    ctx.restore();
  }
}

class StateRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  int width, height;
  CanvasRenderingContext2D stateCq;
  Mapper<State> sm;
  double hungerWidth, cariesWidth, loosenessWidth;

  StateRenderingSystem(CanvasElement canvas)
      : ctx = canvas.context2D,
        width = canvas.width,
        height = canvas.height,
        super(Aspect.getAspectForAllOf([State]));

  void initialize() {
    sm = new Mapper<State>(State, world);

    stateCq = new CanvasElement(width: width, height: height).context2D;
    stateCq
      ..font = '18px Verdana'
      ..textBaseline = 'top'
      ..fillStyle = 'green'
      ..strokeStyle = 'black';

    hungerWidth = stateCq.measureText('Hunger: ').width;
    loosenessWidth = stateCq.measureText('Looseness: ').width;
    cariesWidth = stateCq.measureText('Caries: ').width;
    stateCq
      ..strokeText('Hunger:', width - 100 - hungerWidth, 0)
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
    var s = sm[entity];

    ctx.drawImage(stateCq.canvas, 0, 0);
    ctx.setFillColorRgb(
        50 + s.hunger.toInt() * 2, 200 - s.hunger.toInt() * 2, 0);
    ctx.fillRect(width - 100, 0, s.hunger, 20);
    ctx.setFillColorRgb(
        50 + s.looseness.toInt() * 2, 200 - s.looseness.toInt() * 2, 0);
    ctx.fillRect(width - 100, 25, s.looseness, 20);
    ctx.setFillColorRgb(
        50 + s.caries.toInt() * 2, 200 - s.caries.toInt() * 2, 0);
    ctx.fillRect(width - 100, 50, s.caries, 20);
  }
}

class StartScreenRenderingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  CanvasRenderingContext2D startScreen;
  Rectangle startButtonPos;
  int width, height;
  String startButtonText = '''I'll protect your tooth, Granny!!!''';
  Rectangle<int> buttonBounds;
  bool highlightButton = false;
  SpriteSheet spriteSheet;
  StartScreenRenderingSystem(CanvasElement canvas, this.spriteSheet)
      : canvas = canvas,
        ctx = canvas.context2D,
        width = canvas.width,
        height = canvas.height {}

  void initialize() {
    if (state.startScreen == false) {
      world.deleteSystem(this);
      return;
    }

    startScreen =
        new CanvasElement(width: canvas.width, height: canvas.height).context2D;
    initContext(startScreen);
    var paragraph1 = '''It's Christmas time and you have been wishing
for one special present for a long long time. Your only Grandma has promised 
that you'll get what you wished for. But lately, her only tooth has started
to getting loose.''';
    var paragraph2 =
        '''It's so bad, you have started to worry that she might lose it.
And in the worst case, she might be too sad to celebrate Christmas and you may
not get your present.''';
    var paragraph3 = '''That's why you have decided to make sure she won't lose
her only tooth. You do so by getting her regular appointments at the dentist and
most importantly prevent her from meeting any tooth fairy that might want to get
her hands on such an old and precious tooth.''';

    int textWidth = canvas.width - 140;
    int p1Height = textBoundaries(startScreen, paragraph1, textWidth).height;
    int p2Height = textBoundaries(startScreen, paragraph2, textWidth).height;
    startScreen
      ..fillStyle = '#00BBBB'
      ..fillRect(0, 0, canvas.width, canvas.height)
      ..globalAlpha = 0.9
      ..lineWidth = 3
      ..save()
      ..fillStyle = '#224488'
      ..strokeStyle = 'black'
      ..strokeRect(50, 50, canvas.width - 100, canvas.height - 100)
      ..fillRect(50, 50, canvas.width - 100, canvas.height - 100)
      ..restore()
      ..globalAlpha = 1.0
      ..fillStyle = '#00BBFF';
    wrappedText(startScreen, paragraph1, 70, 70, canvas.width - 140);
    wrappedText(
        startScreen, paragraph2, 70, 70 + p1Height + 10, canvas.width - 140);
    wrappedText(startScreen, paragraph3, 70, 70 + p1Height + 10 + p2Height + 10,
        canvas.width - 140);
    buttonBounds = textBoundaries(startScreen, startButtonText);
    startButtonPos = new Rectangle((width - buttonBounds.width) ~/ 2 - 10,
        height - buttonBounds.height - 200 - 10, buttonBounds.width + 20,
        buttonBounds.height + 20);

    var hiddenButton =
        new CanvasElement(width: width, height: height).context2D;
    hiddenButton
      ..save()
      ..fillStyle = '#010000'
      ..fillRect(startButtonPos.left, startButtonPos.top, startButtonPos.width,
          startButtonPos.height)
      ..restore();

    var mouseMoveSubscription;
    var mouseClickSubscription;
    mouseMoveSubscription = canvas.onMouseMove.listen((event) {
      var data =
          hiddenButton.getImageData(event.offset.x, event.offset.y, 1, 1).data;
      if (data[0] == 1) {
        highlightButton = true;
      } else {
        highlightButton = false;
      }
    });
    mouseClickSubscription = canvas.onMouseUp.listen((event) {
      if (highlightButton) {
        mouseClickSubscription.cancel();
        mouseMoveSubscription.cancel();
        state.startScreen = false;
      }
    });
  }

  void processSystem() {
    startScreen
      ..globalAlpha = 0.8
      ..save()
      ..strokeStyle = 'black'
      ..fillStyle = highlightButton ? '#000088' : '#000044'
      ..strokeRect(startButtonPos.left, startButtonPos.top,
          startButtonPos.width, startButtonPos.height)
      ..fillRect(startButtonPos.left, startButtonPos.top, startButtonPos.width,
          startButtonPos.height)
      ..restore()
      ..globalAlpha = 1.0
      ..fillText(startButtonText, (width - buttonBounds.width) ~/ 2,
          height - buttonBounds.height - 200)
      ..save()
      ..translate(150, height - 150)
      ..drawImageToRect(spriteSheet.image, spriteSheet['granny_big.png'].dst,
          sourceRect: spriteSheet['granny_big.png'].src)
      ..translate(500, 0)
      ..drawImageToRect(spriteSheet.image, spriteSheet['fairy_big.png'].dst,
          sourceRect: spriteSheet['fairy_big.png'].src)
      ..restore();

    ctx.drawImage(startScreen.canvas, 0, 0);
  }

  bool checkProcessing() => state.startScreen;
}

class ButtonRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  CanvasRenderingContext2D buttonCanvas;
  int width, height;
  String startText = 'Go Granny, go!';
  Button startButton,
      restartButton,
      nextLevelButton,
      carrotButton,
      cookiesButton,
      chipsButton;
  ButtonRenderingSystem(CanvasElement canvas)
      : ctx = canvas.context2D,
        width = canvas.width,
        height = canvas.height;

  void initialize() {
    buttonCanvas = new CanvasElement(width: width, height: height).context2D;
    initContext(buttonCanvas);
    var startBounds = textBoundaries(buttonCanvas, startText);
    startButton = new Button(startText, (width - startBounds.width) ~/ 2,
        height - 50, startBounds,
        () => state.grannyWaiting && !state.startScreen);
    restartButton = new Button('Restart Level', 50, height - 50,
        textBoundaries(buttonCanvas, 'Restart Level'), () => true);
    nextLevelButton = new Button('Next Level', width - 200, height - 50,
        textBoundaries(buttonCanvas, 'Next Level'),
        () => state.won && state.level < state.maxLevel);
    carrotButton = new Button('Carrots', 50, 45,
        textBoundaries(buttonCanvas, 'Carrots'), () => state.grannyWaiting);
    carrotButton.selected = true;
    cookiesButton = new Button('Cookies', 200, 45,
        textBoundaries(buttonCanvas, 'Cookies'), () => state.grannyWaiting);
    chipsButton = new Button('Chips', 350, 45,
        textBoundaries(buttonCanvas, 'Chips'), () => state.grannyWaiting);
  }

  void begin() {
    buttonCanvas.clearRect(0, 0, width, height);
  }

  void processSystem() {
    drawButton(startButton);
    drawButton(restartButton);
    drawButton(nextLevelButton);
    drawButton(carrotButton);
    drawButton(cookiesButton);
    drawButton(chipsButton);
    ctx.drawImage(buttonCanvas.canvas, 0, 0);
  }

  void drawButton(Button button) {
    if (button.show) {
      buttonCanvas
        ..save()
        ..fillStyle = button.color
        ..strokeStyle = 'black'
        ..strokeRect(button.pos.left, button.pos.top, button.pos.width,
            button.pos.height)
        ..fillRect(button.pos.left, button.pos.top, button.pos.width,
            button.pos.height)
        ..restore()
        ..fillStyle = button.textColor
        ..fillText(button.label, button.textPos.left, button.textPos.top);
    }
  }
}

class GameLostRenderingSystem extends EntityProcessingSystem {
  Mapper<State> sm;
  CanvasRenderingContext2D ctx;
  int width, height;
  CanvasElement lostHunger, lostLooseness, lostCaries;
  GameLostRenderingSystem(CanvasElement canvas)
      : ctx = canvas.context2D,
        width = canvas.width,
        height = canvas.height,
        super(Aspect.getAspectForAllOf([State]));

  void initialize() {
    sm = new Mapper<State>(State, world);

    var hungerText =
        '''Your Granny is too hungry to move and can't give you your present.''';
    var loosenessText =
        '''Your Granny has lost her only tooth and is now too embarrassed to see you.''';
    var cariesText =
        '''Your Granny's tooth hurts too much and she can't go on.''';

    lostHunger = createLosingScreen(hungerText);
    lostLooseness = createLosingScreen(loosenessText);
    lostCaries = createLosingScreen(cariesText);
  }

  CanvasElement createLosingScreen(String text) {
    var mainText = '''YOU LOST''';
    var screen = new CanvasElement(width: width, height: height).context2D;
    initContext(screen);
    screen.font = '40px Verdana';
    var mainBounds = textBoundaries(screen, mainText);
    screen.font = '16px Verdana';
    var customBounds = textBoundaries(screen, text, width ~/ 2);
    var textHeight = mainBounds.height + customBounds.height + 20;
    screen
      ..fillStyle = '#CCCCCC'
      ..globalAlpha = 0.75
      ..save()
      ..fillStyle = 'darkred'
      ..strokeStyle = 'black'
      ..strokeRect((width - customBounds.width) ~/ 2 - 10,
          (height - textHeight) ~/ 2 - 10, customBounds.width + 20,
          textHeight + 20)
      ..fillRect((width - customBounds.width) ~/ 2 - 10,
          (height - textHeight) ~/ 2 - 10, customBounds.width + 20,
          textHeight + 20)
      ..restore()
      ..globalAlpha = 1.0
      ..font = '40px Verdana'
      ..fillText(
          mainText, (width - mainBounds.width) ~/ 2, (height - textHeight) ~/ 2)
      ..font = '16px Verdana';
    wrappedText(screen, text, (width - customBounds.width) ~/ 2,
        (height - textHeight) ~/ 2 + 20 + mainBounds.height, width ~/ 2);
    return screen.canvas;
  }

  void processEntity(Entity entity) {
    var s = sm[entity];
    CanvasElement toDraw;
    if (s.hunger >= 100) {
      toDraw = lostHunger;
    } else if (s.looseness >= 100) {
      toDraw = lostLooseness;
    } else if (s.caries >= 100) {
      toDraw = lostCaries;
    }
    ctx.drawImage(toDraw, 0, 0);
  }

  bool checkProcessing() => state.lost;
}

class LevelCompletedRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  CanvasElement winCanvas;
  int width, height;
  LevelCompletedRenderingSystem(CanvasElement canvas)
      : ctx = canvas.context2D,
        width = canvas.width,
        height = canvas.height;

  void initialize() {
    var screen = new CanvasElement(width: width, height: height).context2D;
    initContext(screen);
    var mainText = '''LEVEL COMPLETE''';
    screen.font = '34px Verdana';
    var bounds = textBoundaries(screen, mainText);
    screen
      ..fillStyle = '#CCCCCC'
      ..globalAlpha = 0.75
      ..save()
      ..fillStyle = 'darkgreen'
      ..strokeStyle = 'black'
      ..strokeRect((width - bounds.width) ~/ 2 - 10,
          (height - bounds.height) ~/ 2 - 10, bounds.width + 20,
          bounds.height + 20)
      ..fillRect((width - bounds.width) ~/ 2 - 10,
          (height - bounds.height) ~/ 2 - 10, bounds.width + 20,
          bounds.height + 20)
      ..restore()
      ..globalAlpha = 1.0
      ..font = '34px Verdana'
      ..fillText(
          mainText, (width - bounds.width) ~/ 2, (height - bounds.height) ~/ 2);
    winCanvas = screen.canvas;
  }

  void processSystem() {
    ctx.drawImage(winCanvas, 0, 0);
  }

  bool checkProcessing() => state.won && state.level < state.maxLevel;
}

class GameWonRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  CanvasElement winCanvas;
  int width, height;
  GameWonRenderingSystem(CanvasElement canvas)
      : ctx = canvas.context2D,
        width = canvas.width,
        height = canvas.height;

  void initialize() {
    var screen = new CanvasElement(width: width, height: height).context2D;
    initContext(screen);
    var mainText = '''YOU'VE WON''';
    var text = '''Thanks to your valiant effort your Granny was able to keep her
loose tooth until Christmas. With joy in your eyes you receive your Christmas
present and start unpacking it. It's just as you imagined. All you can give your
Granny are 'Thank you's, hugs and kisses. You finally have what everyone would
love to have: A beautiful FROZEN NINJA KITTEN.''';
    screen.font = '40px Verdana';
    var mainBounds = textBoundaries(screen, mainText);
    screen.font = '16px Verdana';
    var customBounds = textBoundaries(screen, text, width ~/ 2);
    var textHeight = mainBounds.height + customBounds.height + 20;
    screen
      ..fillStyle = '#CCCCCC'
      ..globalAlpha = 0.75
      ..save()
      ..fillStyle = 'darkgreen'
      ..strokeStyle = 'black'
      ..strokeRect((width - customBounds.width) ~/ 2 - 10,
          (height - textHeight) ~/ 2 - 10, customBounds.width + 20,
          textHeight + 20)
      ..fillRect((width - customBounds.width) ~/ 2 - 10,
          (height - textHeight) ~/ 2 - 10, customBounds.width + 20,
          textHeight + 20)
      ..restore()
      ..globalAlpha = 1.0
      ..font = '40px Verdana'
      ..fillText(
          mainText, (width - mainBounds.width) ~/ 2, (height - textHeight) ~/ 2)
      ..font = '16px Verdana';
    wrappedText(screen, text, (width - customBounds.width) ~/ 2,
        (height - textHeight) ~/ 2 + 20 + mainBounds.height, width ~/ 2);
    winCanvas = screen.canvas;
  }

  void processSystem() {
    ctx.drawImage(winCanvas, 0, 0);
  }

  bool checkProcessing() => state.won && state.level == state.maxLevel;
}
