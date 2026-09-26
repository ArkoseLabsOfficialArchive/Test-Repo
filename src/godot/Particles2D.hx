package godot;

class Particles2D extends Node2D {
	public var emitting:Bool;
	public var amount:Int;
	public var lifetime:Float;

	public function new() {
		super();

		emitting = false;
		amount = 8;
		lifetime = 1.0;
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "emitting":
				if (value.boolValue != null) {
					emitting = value.boolValue;
					return true;
				}

			case "amount":
				if (value.intValue != null) {
					amount = value.intValue;
					return true;
				}

			case "lifetime":
				if (value.floatValue != null) {
					lifetime = value.floatValue;
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
