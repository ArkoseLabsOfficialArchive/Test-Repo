package godot;

class Button extends Control {
	public var text:String;
	public var pressed:Bool;
	public var hovered:Bool;
	public var disabled:Bool;

	public function new() {
		super();

		text = "";
		pressed = false;
		hovered = false;
		disabled = false;

		mouseFilter = MouseFilter.Stop;
		focusMode = FocusMode.Click;

		add_user_signal("pressed");
	}

	public function set_text(value:String):Void {
		if (text != value) {
			text = value;
			mark_dirty(DirtyFlag.Text);
		}
	}

	override public function gui_input(event:InputEvent):Void {
		if (disabled) {
			return;
		}

		var mouse:Null<InputEventMouseButton> = event.as_mouse_button();
		if (mouse == null || mouse.buttonIndex != 1) {
			return;
		}

		if (mouse.pressed) {
			if (has_global_point(mouse.position)) {
				pressed = true;
				event.set_handled();
			}
		} else {
			if (pressed) {
				pressed = false;

				if (has_global_point(mouse.position)) {
					handle_release();
				}

				event.set_handled();
			}
		}
	}

	function handle_release():Void {
		emit_signal("pressed", []);
	}

	override public function call_method(methodName:String, args:Array<Dynamic>):Bool {
		if (methodName == "emit_pressed") {
			emit_signal("pressed", []);
			return true;
		}

		return super.call_method(methodName, args);
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "text" && value.stringValue != null) {
			set_text(value.stringValue);
			return true;
		}

		if (name == "disabled" && value.boolValue != null) {
			disabled = value.boolValue;
			mark_dirty(DirtyFlag.Visual);
			return true;
		}

		return super.set_property(name, value, doc);
	}
}
