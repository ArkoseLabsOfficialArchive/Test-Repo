package godot;

class CheckBox extends Button {
	public var checked:Bool;

	public function new() {
		super();
		checked = false;
		add_user_signal("toggled");
	}

	override function handle_release():Void {
		checked = !checked;
		emit_signal("toggled", [checked]);
		super.handle_release();
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "pressed" && value.boolValue != null) {
			checked = value.boolValue;
			return true;
		}

		return super.set_property(name, value, doc);
	}
}
