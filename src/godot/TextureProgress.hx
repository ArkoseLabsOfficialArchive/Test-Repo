package godot;

class TextureProgress extends Control {
	public var minValue:Float;
	public var maxValue:Float;
	public var value:Float;

	public var textureUnder:Null<Texture>;
	public var textureProgress:Null<Texture>;

	public function new() {
		super();

		minValue = 0.0;
		maxValue = 100.0;
		value = 0.0;

		textureUnder = null;
		textureProgress = null;

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

			case "texture_under":
				var underResource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				textureUnder = Std.instance(underResource, Texture);
				mark_dirty(DirtyFlag.Texture);
				return true;

			case "texture_progress":
				var progressResource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				textureProgress = Std.instance(progressResource, Texture);
				mark_dirty(DirtyFlag.Texture);
				return true;
		}

		return super.set_property(name, value, doc);
	}
}
