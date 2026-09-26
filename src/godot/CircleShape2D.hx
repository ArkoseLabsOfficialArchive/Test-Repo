package godot;

class CircleShape2D extends Shape2D {
    public var radius:Float;

    public function new(radius:Float = 10.0) {
        super();
        this.radius = radius;
    }

    override public function get_rect():Rect2 {
        return Rect2.from_xywh(-radius, -radius, radius * 2.0, radius * 2.0);
    }
}