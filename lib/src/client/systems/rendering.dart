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
    ctx.fillRect(t.x, t.y, 10, 10);
  }
}