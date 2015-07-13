part of shared;

class SpriteDirectionSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<Renderable> rm;
  SpriteDirectionSystem()
      : super(Aspect.getAspectForAllOf([Transform, Renderable, Directed]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    rm = new Mapper<Renderable>(Renderable, world);
  }

  void processEntity(Entity entity) {
    rm[entity].subspriteName = tm[entity].direction;
  }
}

class HungerSystem extends IntervalEntitySystem {
  Mapper<State> sm;
  HungerSystem() : super(
          0.2, Aspect.getAspectForAllOf([State]).exclude([Eating, Waiting]));

  void initialize() {
    sm = new Mapper<State>(State, world);
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    entities.forEach((entity) {
      var s = sm[entity];
      s.hunger = min(100.0, s.hunger + 2);
    });
  }
}

class FoodDigestionSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<State> sm;
  Mapper<Food> fm;
  Mapper<Eating> em;
  List<Entity> foodEntities;
  TerrainMap map;
  FoodDigestionSystem() : super(Aspect.getAspectForAllOf([Transform, State]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    sm = new Mapper<State>(State, world);
    fm = new Mapper<Food>(Food, world);
    em = new Mapper<Eating>(Eating, world);

    initFoodMap();
  }

  void initFoodMap() {
    foodEntities = new List(MAX_WIDTH * MAX_HEIGHT);
  }

  void processEntity(Entity entity) {
    var t = tm[entity];
    var index = indexInGrid(t.x, t.y);
    var food = foodEntities[index];
    if (null != food) {
      var s = sm[entity];
      var f = fm[food];
      var mult = world.delta / f.timeToEat;
      s.hunger = max(0.0, min(100.0, s.hunger - f.filling * mult));
      s.looseness = max(0.0, min(100.0, s.looseness + f.hardness * mult));
      s.caries = max(0.0, min(100.0, s.caries + f.sweetness * mult));
      if (f.timeLeftToEat == f.timeToEat) {
        var eatingSound = world.createEntity();
        eatingSound.addComponent(new Sound(f.name));
        eatingSound.addToWorld();
      }
      f.timeLeftToEat -= world.delta;
      var eating = em.getSafe(entity);
      if (null == eating) {
        entity.addComponent(new Eating());
        entity.changedInWorld();
      }
      if (f.timeLeftToEat < 0.0) {
        foodEntities[index] = null;
        map.free(index);
        food.deleteFromWorld();
        entity.removeComponent(Eating);
        entity.changedInWorld();
      }
    }
  }
}

class StateObservationSystem extends EntityProcessingSystem {
  Mapper<State> sm;
  StateObservationSystem() : super(Aspect.getAspectForAllOf([State]));

  void initialize() {
    sm = new Mapper<State>(State, world);
  }

  void processEntity(Entity entity) {
    var s = sm[entity];
    if (s.hunger >= 100) {
      entity.addComponent(new Waiting());
      entity.changedInWorld();
      state.lost = true;
    }
    if (s.looseness >= 100) {
      entity.addComponent(new Waiting());
      entity.changedInWorld();
      state.lost = true;
    }
    if (s.caries >= 100) {
      entity.addComponent(new Waiting());
      entity.changedInWorld();
      state.lost = true;
    }
  }
}

class FairyEncounterSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<State> sm;
  List<bool> fairyEntities;
  FairyEncounterSystem() : super(Aspect.getAspectForAllOf([State, Transform]));

  void initialize() {
    tm = new Mapper<Transform>(Transform, world);
    sm = new Mapper<State>(State, world);
  }

  void processEntity(Entity entity) {
    var t = tm[entity];
    var index = indexInGrid(t.x, t.y);
    if (fairyEntities[index]) {
      sm[entity].looseness = 100.0;
    }
  }
}
