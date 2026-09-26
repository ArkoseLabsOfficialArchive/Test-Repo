package godot;

class HBoxContainer extends Control {
	public var separation:Float;

	public function new() {
		super();
		separation = 4.0;
		mouseFilter = MouseFilter.Pass;
	}

	override public function arrange_children():Void {
		var x:Float = 0.0;

		for (child in get_children()) {
			var control:Null<Control> = Std.instance(child, Control);
			if (control == null || !control.visible) {
				continue;
			}

			var size:Vector2 = control.get_combined_minimum_size();

			if (size.x <= 0.0) {
				size.x = control.rectSize.x;
			}

			if (size.y <= 0.0) {
				size.y = rectSize.y;
			}

			control.set_position_no_propagate(new Vector2(x, 0.0));
			control.set_size_no_propagate(size);

			x += size.x + separation;
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "custom_constants/separation" && value.floatValue != null) {
			separation = value.floatValue;
			layoutDirty = true;
			return true;
		}

		return super.set_property(name, value, doc);
	}
}
