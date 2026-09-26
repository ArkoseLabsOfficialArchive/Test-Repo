package godot;

class ControlGuiState {
    public var hovered:Null<Control>;
    public var pressed:Null<Control>;
    public var focused:Null<Control>;

    public function new() {
        hovered = null;
        pressed = null;
        focused = null;
    }

    public function clear():Void {
        hovered = null;
        pressed = null;
        focused = null;
    }
}