package godot;

class Shape2D extends Resource {
    public function new() {
        super();
    }

    public function get_rect():Rect2 {
        return Rect2.from_xywh(0, 0, 0, 0);
    }
}