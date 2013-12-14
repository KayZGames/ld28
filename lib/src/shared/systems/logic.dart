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
  HungerSystem() : super(200, Aspect.getAspectForAllOf([State]));

  void initialize() {
    sm = new ComponentMapper<State>(State, world);
  }

  void processEntity(Entity entity) {
    var s = sm.get(entity);
    s.hunger = min(100, s.hunger + 1);
  }
}

class FoodDigestionSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<State> sm;
  ComponentMapper<Food> fm;
  List<Entity> foodEntities;
  FoodDigestionSystem() : super(Aspect.getAspectForAllOf([Transform, State]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
    sm = new ComponentMapper<State>(State, world);
    fm = new ComponentMapper<Food>(Food, world);

    foodEntities = new List(MAX_WIDTH * MAX_HEIGHT);
    GroupManager gm = world.getManager(GroupManager);
    var foodGroup = gm.getEntities('food');
    foodGroup.forEach((food) {
      var t = tm.get(food);
      foodEntities[indexInGrid(t.x, t.y)] = food;
    });
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var index = indexInGrid(t.x, t.y);
    var food = foodEntities[index];
    if (null != food) {
      var s = sm.get(entity);
      var f = fm.get(food);
      s.hunger = max(0, s.hunger - f.filling);
      s.looseness = min(100, s.looseness + f.hardness);
      s.caries = min(100, s.caries + f.sweetness);
      foodEntities[index] = null;
      food.deleteFromWorld();
    }
  }
}


