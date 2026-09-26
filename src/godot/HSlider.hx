package godot;

class HSlider extends Control {
	public var minValue:Float;
	public var maxValue:Float;
	public var value:Float;

	var dragging:Bool;

	public function new() {
		super();

		minValue = 0.0;
		maxValue = 100.0;
		value = 0.0;
		dragging = false;

		mouseFilter = MouseFilter.Stop;
		focusMode = FocusMode.Click;

		add_user_signal("value_changed");
	}

	public function set_value(newValue:Float):Void {
		var clamped:Float = newValue;

		if (clamped < minValue)
			clamped = minValue;
		if (clamped > maxValue)
			clamped = maxValue;

		if (value != clamped) {
			value = clamped;
			mark_dirty(DirtyFlag.Visual);
			emit_signal("value_changed", [value]);
		}
	}

	public function get_ratio():Float {
		if (maxValue == minValue) {
			return 0.0;
		}

		var ratio:Float = (value - minValue) / (maxValue - minValue);

		if (ratio < 0.0)
			ratio = 0.0;
		if (ratio > 1.0)
			ratio = 1.0;

		return ratio;
	}

	override public function gui_input(event:InputEvent):Void {
		var mouseButton:Null<InputEventMouseButton> = event.as_mouse_button();
		if (mouseButton != null && mouseButton.buttonIndex == 1) {
			if (mouseButton.pressed) {
				if (has_global_point(mouseButton.position)) {
					dragging = true;
					update_from_mouse(mouseButton.position);
					event.set_handled();
				}
			} else {
				if (dragging) {
					dragging = false;
					event.set_handled();
				}
			}

			return;
		}

		var mouseMotion:Null<InputEventMouseMotion> = event.as_mouse_motion();
		if (mouseMotion != null && dragging) {
			update_from_mouse(mouseMotion.position);
			event.set_handled();
		}
	}

	function update_from_mouse(point:Vector2):Void {
		var globalRect:Rect2 = get_global_rect();

		if (globalRect.size.x <= 0.0) {
			return;
		}

		var ratio:Float = (point.x - globalRect.position.x) / globalRect.size.x;

		if (ratio < 0.0)
			ratio = 0.0;
		if (ratio > 1.0)
			ratio = 1.0;

		set_value(minValue + ratio * (maxValue - minValue));
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "min_value":
				if (value.floatValue != null) {
					minValue = value.floatValue;
					return true;
				}

			case "max_value":
				if (value.floatValue != null) {
					maxValue = value.floatValue;
					return true;
				}

			case "value":
				if (value.floatValue != null) {
					set_value(value.floatValue);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
