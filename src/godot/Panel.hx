package godot;

class Panel extends Control {
	public var color:Color;

	public function new() {
		super();
		color = new Color(0.12, 0.12, 0.12, 0.9);
		mouseFilter = MouseFilter.Pass;
	}

	public function set_color(value:Color):Void {
		color = value;
		mark_dirty(DirtyFlag.Visual);
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "color" && value.colorValue != null) {
			set_color(value.colorValue);
			return true;
		}

		return super.set_property(name, value, doc);
	}
}
