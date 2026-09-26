package godot;

class InputEventMouseButton extends InputEventMouse {
    public var buttonIndex:Int;
    public var pressed:Bool;

    public function new(buttonIndex:Int = 0, pressed:Bool = false) {
        super();
        this.buttonIndex = buttonIndex;
        this.pressed = pressed;
    }
}