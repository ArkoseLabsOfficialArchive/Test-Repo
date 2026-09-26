package godot;

class PathFollow2D extends Node2D {
	public var unitOffset:Float;
	public var loop:Bool;

	var pathNode:Null<Path2D>;

	public function new() {
		super();
		unitOffset = 0.0;
		loop = true;
	}

	override public function _enter_tree():Void {
		super._enter_tree();
		pathNode = Std.instance(parent, Path2D);
	}

	override public function _process(delta:Float):Void {
		if (pathNode == null || pathNode.curve == null)
			return;
		set_position(pathNode.curve.sample(unitOffset));
	}

	public function set_unit_offset(value:Float):Void {
		unitOffset = value;
		if (loop) {
			while (unitOffset > 1.0)
				unitOffset -= 1.0;
			while (unitOffset < 0.0)
				unitOffset += 1.0;
		} else {
			if (unitOffset < 0)
				unitOffset = 0;
			if (unitOffset > 1)
				unitOffset = 1;
		}
	}
}
