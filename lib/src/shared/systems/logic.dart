part of shared;


class SpriteDirectionSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;
  SpriteDirectionSystem() : super(Aspect.getAspectForAllOf([Transform, Renderable, Directed]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    rm = new ComponentMapper<Renderable>(Renderable, world);
  }

  void processEntity(Entity entity) {
    rm.get(entity).subspriteName = tm.get(entity).direction;
  }
}

class HungerSystem extends IntervalEntityProcessingSystem {
  ComponentMapper<State> sm;
  HungerSystem() : super(200, Aspect.getAspectForAllOf([State]).exclude([Eating, Waiting]));

  void initialize() {
    sm = new ComponentMapper<State>(State, world);
  }

  void processEntity(Entity entity) {
    var s = sm.get(entity);
    s.hunger = min(100.0, s.hunger + 1);
  }
}

class FoodDigestionSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<State> sm;
  ComponentMapper<Food> fm;
  ComponentMapper<Eating> em;
  List<Entity> foodEntities;
  TerrainMap map;
  FoodDigestionSystem() : super(Aspect.getAspectForAllOf([Transform, State]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    sm = new ComponentMapper<State>(State, world);
    fm = new ComponentMapper<Food>(Food, world);
    em = new ComponentMapper<Eating>(Eating, world);

    initFoodMap();
  }

  void initFoodMap() {
    foodEntities = new List(MAX_WIDTH * MAX_HEIGHT);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var index = indexInGrid(t.x, t.y);
    var food = foodEntities[index];
    if (null != food) {
      var s = sm.get(entity);
      var f = fm.get(food);
      var mult = world.delta/f.timeToEat;
      s.hunger = max(0.0, s.hunger - f.filling * mult);
      s.looseness = min(100.0, s.looseness + f.hardness * mult);
      s.caries = min(100.0, s.caries + f.sweetness * mult);
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
