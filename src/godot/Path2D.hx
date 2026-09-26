package godot;

class Path2D extends Node2D {
	public var curve:Curve2D;

	public function new() {
		super();
		curve = new Curve2D();
	}
}
