package godot;

class InputActionBinding {
    public var action:String;
    public var keyCode:Null<Int>;
    public var mouseButton:Null<Int>;

    public function new(action:String, ?keyCode:Int, ?mouseButton:Int) {
        this.action = action;
        this.keyCode = keyCode;
        this.mouseButton = mouseButton;
    }
}

class InputActionState {
    public var pressed:Bool;
    public var justPressed:Bool;
    public var justReleased:Bool;

    public function new() {
        pressed = false;
        justPressed = false;
        justReleased = false;
    }

    public function update(newPressed:Bool):Void {
        justPressed = newPressed && !pressed;
        justReleased = !newPressed && pressed;
        pressed = newPressed;
    }

    public function finish_frame():Void {
        justPressed = false;
        justReleased = false;
    }
}

class Input extends Object {
    public static var instance:Input = new Input();

    var keyState:Map<Int, Bool>;
    var prevKeyState:Map<Int, Bool>;
    var mouseState:Map<Int, Bool>;
    var prevMouseState:Map<Int, Bool>;
    var actionState:Map<String, InputActionState>;
    var bindings:Array<InputActionBinding>;

    public var mousePosition:Vector2;

    function new() {
        super();
        keyState = new Map<Int, Bool>();
        prevKeyState = new Map<Int, Bool>();
        mouseState = new Map<Int, Bool>();
        prevMouseState = new Map<Int, Bool>();
        actionState = new Map<String, InputActionState>();
        bindings = [];
        mousePosition = new Vector2(0, 0);
    }

    public function add_action_binding(binding:InputActionBinding):Void {
        bindings.push(binding);
        if (!actionState.exists(binding.action)) {
            actionState.set(binding.action, new InputActionState());
        }
    }

    public function parse_event(event:InputEvent):Void {
        var key:Null<InputEventKey> = event.as_key();
        if (key != null) {
            keyState.set(key.keyCode, key.pressed);
            update_actions();
            return;
        }

        var mouseButton:Null<InputEventMouseButton> = event.as_mouse_button();
        if (mouseButton != null) {
            mouseState.set(mouseButton.buttonIndex, mouseButton.pressed);
            mousePosition = mouseButton.position.copy();
            update_actions();
            return;
        }

        var mouseMotion:Null<InputEventMouseMotion> = event.as_mouse_motion();
        if (mouseMotion != null) {
            mousePosition = mouseMotion.position.copy();
            return;
        }
    }

    function update_actions():Void {
        var pressedByAction:Map<String, Bool> = new Map<String, Bool>();

        for (binding in bindings) {
            var pressed:Bool = false;

            if (binding.keyCode != null) {
                pressed = pressed || is_key_pressed(binding.keyCode);
            }

            if (binding.mouseButton != null) {
                pressed = pressed || is_mouse_button_pressed(binding.mouseButton);
            }

            pressedByAction.set(binding.action, pressed);
        }

        for (action in pressedByAction.keys()) {
            var state:Null<InputActionState> = actionState.get(action);
            if (state == null) {
                state = new InputActionState();
                actionState.set(action, state);
            }

            var pressed:Null<Bool> = pressedByAction.get(action);
            state.update(pressed == true);
        }
    }

    public function is_key_pressed(keyCode:Int):Bool {
        return keyState.get(keyCode) == true;
    }

    public function is_key_just_pressed(keyCode:Int):Bool {
        return is_key_pressed(keyCode) && prevKeyState.get(keyCode) != true;
    }

    public function is_key_just_released(keyCode:Int):Bool {
        return !is_key_pressed(keyCode) && prevKeyState.get(keyCode) == true;
    }

    public function is_mouse_button_pressed(button:Int):Bool {
        return mouseState.get(button) == true;
    }

    public function is_action_pressed(action:String):Bool {
        var state:Null<InputActionState> = actionState.get(action);
        return state != null && state.pressed;
    }

    public function is_action_just_pressed(action:String):Bool {
        var state:Null<InputActionState> = actionState.get(action);
        return state != null && state.justPressed;
    }

    public function is_action_just_released(action:String):Bool {
        var state:Null<InputActionState> = actionState.get(action);
        return state != null && state.justReleased;
    }

    public function get_action_strength(action:String):Float {
        return is_action_pressed(action) ? 1.0 : 0.0;
    }

    public function end_frame():Void {
        prevKeyState = keyState.copy();
        prevMouseState = mouseState.copy();

        for (state in actionState) {
            state.finish_frame();
        }
    }
}