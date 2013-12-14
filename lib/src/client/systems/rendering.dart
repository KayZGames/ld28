part of client;

class RenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  ComponentMapper<Transform> tm;
  RenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Transform]));

  void initialize() {
    tm = new ComponentMapper<Transform>(Transform, world);
  }

  void processEntity(Entity entity) {
    var t = tm.get(entity);
    ctx.fillStyle = 'black';
    ctx.fillRect(t.x * GRID_SIZE, t.y * GRID_SIZE, GRID_SIZE, GRID_SIZE);
  }
}


class TerrainRenderingSystem extends EntityProcessingSystem {
  CanvasRenderingContext2D ctx;
  ComponentMapper<TerrainTile> tm;
  TerrainRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([TerrainTile]));

  void initialize() {
    tm = new ComponentMapper<TerrainTile>(TerrainTile, world);
  }


  void processEntity(Entity entity) {
    var t = tm.get(entity);
    ctx.fillStyle = t.sprite;
    ctx.fillRect(t.x * GRID_SIZE, t.y * GRID_SIZE, GRID_SIZE, GRID_SIZE);
  }
}