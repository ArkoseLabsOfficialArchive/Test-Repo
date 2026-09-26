package godot;

class InputEventMouseMotion extends InputEventMouse {
    public var relative:Vector2;
    public var velocity:Vector2;

    public function new() {
        super();
        relative = new Vector2(0, 0);
        velocity = new Vector2(0, 0);
    }
}