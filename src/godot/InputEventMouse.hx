package godot;

class InputEventMouse extends InputEvent {
    public var position:Vector2;
    public var globalPosition:Vector2;

    public function new() {
        super();
        position = new Vector2(0, 0);
        globalPosition = new Vector2(0, 0);
    }
}