package godot;

class InputEventAction extends InputEvent {
    public var action:String;
    public var pressed:Bool;

    public function new(action:String = "", pressed:Bool = false) {
        super();
        this.action = action;
        this.pressed = pressed;
    }
}