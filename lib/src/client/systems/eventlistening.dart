part of client;

class MouseMovementListeningSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  TerrainMap map;
  CanvasElement canvas;
  int x = 0, y = 0;
  MouseMovementListeningSystem(this.canvas, this.map) : super(Aspect.getAspectForAllOf([Mouse, Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);

    canvas.onMouseMove.listen((data) {
      x = (GRID_SIZE~/2 + data.offset.x) ~/ GRID_SIZE;
      y = (GRID_SIZE~/2 + data.offset.y) ~/ GRID_SIZE;
    });
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var gx = min(max(0, x), MAX_WIDTH-  1);
    var gy = min(max(0, y), MAX_HEIGHT - 1);
    var index = indexInGrid(gx, gy);
    if (map.occupiable(index)) {
      t.x = gx;
      t.y = gy;
    }
  }
}

class MouseClickListeningSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  CanvasElement canvas;
  bool clicked = false;
  FoodDigestionSystem fds;
  TerrainMap map;
  MouseClickListeningSystem(this.canvas, this.map) : super(Aspect.getAspectForAllOf([Mouse, Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    fds = world.getSystem(FoodDigestionSystem);

    canvas.onMouseDown.listen((_) => clicked = true);
    canvas.onMouseUp.listen((_) => clicked = false);
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
    }
  }

  bool checkProcessing() => !state.startScreen && clicked;
}

class GameStateModificationSystem extends EntityProcessingSystem {
  CanvasElement canvas;
  bool waiting = true;
  GameStateModificationSystem(this.canvas) : super(Aspect.getAspectForAllOf([Waiting]));

  void initialize() {
    canvas.onMouseUp.listen((_) => waiting = state.startScreen);
  }

  void processEntity(Entity entity) {
    entity.removeComponent(Waiting);
    entity.changedInWorld();
  }

  bool checkProcessing() => !waiting;
}