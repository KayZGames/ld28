part of client;

class MouseMovementListeningSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;
  TerrainMap map;
  CanvasElement canvas;
  int x = 0, y = 0;
  MouseMovementListeningSystem(this.canvas) : super(Aspect.getAspectForAllOf([Mouse, Transform, Renderable]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    rm = new ComponentMapper<Renderable>(Renderable, world);

    canvas.onMouseMove.listen((data) {
      x = (GRID_SIZE~/2 + data.offset.x) ~/ GRID_SIZE;
      y = (GRID_SIZE~/2 + data.offset.y) ~/ GRID_SIZE;
    });
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var r = rm.get(entity);
    var gx = min(max(0, x), MAX_WIDTH-  1);
    var gy = min(max(0, y), MAX_HEIGHT - 1);
    var index = indexInGrid(gx, gy);
    t.x = gx;
    t.y = gy;
    if (map.occupiable(index)) {
      r.subspriteName = '';
    } else {
      r.subspriteName= '_hidden';
    }
  }
}

class FoodDispenserSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  CanvasElement canvas;
  bool clicked = false;
  FoodDigestionSystem fds;
  TerrainMap map;
  FoodDispenserSystem(this.canvas) : super(Aspect.getAspectForAllOf([Mouse, Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    fds = world.getSystem(FoodDigestionSystem);

    canvas.onMouseUp.listen((_) => clicked = true);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var index = indexInGrid(t.x, t.y);
    if (fds.foodEntities[index] == null && map.acceptsOccupant(index)) {
      var food = world.createEntity();
      food.addComponent(new Transform(t.x, t.y));
      food.addComponent(new Food(filling: 20.0, hardness: 50.0, sweetness: 5.0));
      food.addComponent(new Renderable('carrot'));
      food.addToWorld();
      fds.foodEntities[index] = food;
      map.occupy(index, -100);
    } else if (fds.foodEntities[index] != null) {
      var food = fds.foodEntities[index];
      fds.foodEntities[index] = null;
      food.deleteFromWorld();
      map.free(index);
    }
    clicked = false;
  }

  bool checkProcessing() => !state.startScreen && state.grannyWaiting && clicked;
}

class GameStateModificationSystem extends EntityProcessingSystem {
  static const START = 1;
  static const RESTART = 2;
  static const NEXT_LEVEL = 3;
  CanvasElement canvas;
  ButtonRenderingSystem brs;
  LevelLoadingSystem lls;
  Map<int, Button> buttons = new Map<int, Button>();
  int highlightId = 0;
  GameStateModificationSystem(this.canvas) : super(Aspect.getAspectForAllOf([Waiting]));

  void initialize() {
    brs = world.getSystem(ButtonRenderingSystem);
    lls = world.getSystem(LevelLoadingSystem);
    buttons[0] = new Button.dummy();
    CanvasQuery buttonCanvas = cq(canvas.width, canvas.height);
    addButton(buttonCanvas, brs.startButton, START);
    addButton(buttonCanvas, brs.restartButton, RESTART);
    addButton(buttonCanvas, brs.nextLevelButton, NEXT_LEVEL);

    canvas.onMouseMove.listen((event) {
      var data = buttonCanvas.getImageData(event.offset.x, event.offset.y, 1, 1).data;
      var id = data[0];
      if (id != 0 && data[3] == 255 && buttons.containsKey(id)) {
        buttons[highlightId].highlight = false;
        buttons[id].highlight = true;
        highlightId = id;
      } else {
        buttons[highlightId].highlight = false;
        highlightId = 0;
      }
    });

    canvas.onMouseUp.listen((_) {
      if (!state.startScreen && buttons[highlightId] != null && buttons[highlightId].show) {
        switch (highlightId) {
          case START:
            state.grannyWaiting = false;
            break;
          case RESTART:
            lls.loadLevel = true;
            break;
          case NEXT_LEVEL:
            state.level = min(state.maxLevel, state.level + 1);
            lls.loadLevel = true;
            break;
        }
      }
    });
  }

  void addButton(CanvasQuery buttonCanvas, Button button, int id) {
    buttonCanvas..roundRect(button.pos.left, button.pos.top, button.pos.width, button.pos.height, button.radius, fillStyle: '0${id}0000');
    buttons[id] = button;
  }

  void processEntity(Entity entity) {
    entity.removeComponent(Waiting);
    entity.changedInWorld();
  }

  bool checkProcessing() => !state.grannyWaiting && !state.lost && !state.won;
}