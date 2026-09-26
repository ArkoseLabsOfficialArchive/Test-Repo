package godot;

class InputEvent extends Object {
	public var device:Int;
	public var handled:Bool;

	public function new() {
		super();
		device = 0;
		handled = false;
	}

	public function set_handled():Void {
		handled = true;
	}

	public function as_key():Null<InputEventKey> {
		return Std.instance(this, InputEventKey);
	}

	public function as_mouse_button():Null<InputEventMouseButton> {
		return Std.instance(this, InputEventMouseButton);
	}

	public function as_mouse_motion():Null<InputEventMouseMotion> {
		return Std.instance(this, InputEventMouseMotion);
	}

	public function as_action():Null<InputEventAction> {
		return Std.instance(this, InputEventAction);
	}
}
