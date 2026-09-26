package godot;

class GridContainer extends Control {
	public var columns:Int;
	public var separation:Float;

	public function new() {
		super();
		columns = 1;
		separation = 4.0;
		mouseFilter = MouseFilter.Pass;
	}

	override public function arrange_children():Void {
		var x:Float = 0.0;
		var y:Float = 0.0;
		var col:Int = 0;
		var maxRowHeight:Float = 0.0;

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
				size.y = control.rectSize.y;
			}

			control.set_position_no_propagate(new Vector2(x, y));
			control.set_size_no_propagate(size);

			x += size.x + separation;

			if (size.y > maxRowHeight) {
				maxRowHeight = size.y;
			}

			col++;

			if (col >= columns) {
				col = 0;
				x = 0.0;
				y += maxRowHeight + separation;
				maxRowHeight = 0.0;
			}
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (name == "columns" && value.intValue != null) {
			columns = value.intValue;
			layoutDirty = true;
			return true;
		}

		return super.set_property(name, value, doc);
	}
}
