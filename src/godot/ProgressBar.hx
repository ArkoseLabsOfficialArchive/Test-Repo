package godot;

class ProgressBar extends Control {
	public var minValue:Float;
	public var maxValue:Float;
	public var value:Float;

	public function new() {
		super();

		minValue = 0.0;
		maxValue = 100.0;
		value = 0.0;
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
