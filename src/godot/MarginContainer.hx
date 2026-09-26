package godot;

class MarginContainer extends Control {
	public var containerMarginLeft:Float;
	public var containerMarginRight:Float;
	public var containerMarginTop:Float;
	public var containerMarginBottom:Float;

	public function new() {
		super();
		containerMarginLeft = 0.0;
		containerMarginRight = 0.0;
		containerMarginTop = 0.0;
		containerMarginBottom = 0.0;
		mouseFilter = MouseFilter.Pass;
	}

	override public function arrange_children():Void {
		var childWidth:Float = rectSize.x - containerMarginLeft - containerMarginRight;
		var childHeight:Float = rectSize.y - containerMarginTop - containerMarginBottom;
		if (childWidth < 0.0)
			childWidth = 0.0;
		if (childHeight < 0.0)
			childHeight = 0.0;

		for (child in get_children()) {
			var control:Null<Control> = Std.instance(child, Control);
			if (control == null || !control.visible)
				continue;
			control.set_position_no_propagate(new Vector2(containerMarginLeft, containerMarginTop));
			control.set_size_no_propagate(new Vector2(childWidth, childHeight));
		}
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		if (StringTools.startsWith(name, "custom_constants/")) {
			var marginName:String = name.substr("custom_constants/".length);
			var val:Null<Float> = null;

			// FIX: Accept both float and int values from the parser
			if (value.floatValue != null)
				val = value.floatValue;
			else if (value.intValue != null)
				val = value.intValue;

			if (val != null) {
				switch (marginName) {
					case "margin_left":
						containerMarginLeft = val;
					case "margin_right":
						containerMarginRight = val;
					case "margin_top":
						containerMarginTop = val;
					case "margin_bottom":
						containerMarginBottom = val;
					default:
						return super.set_property(name, value, doc);
				}
				layoutDirty = true;
				mark_dirty(DirtyFlag.Layout);
				return true;
			}
		}
		return super.set_property(name, value, doc);
	}
}
