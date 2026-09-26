package godot;

class RectangleShape2D extends Shape2D {
    public var size:Vector2;

    public function new(size:Vector2 = null) {
        super();
        this.size = size != null ? size : new Vector2(10, 10);
    }

    override public function get_rect():Rect2 {
        return new Rect2(
            new Vector2(-size.x * 0.5, -size.y * 0.5),
            size.copy()
        );
    }
}