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