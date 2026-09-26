package godot.physics;

import godot.Vector2;

class CollisionResult2D {
	public var collided:Bool;
	public var normal:Vector2;
	public var position:Vector2;
	public var remainder:Vector2;

	public function new() {
		collided = false;
		normal = new Vector2(0, 0);
		position = new Vector2(0, 0);
		remainder = new Vector2(0, 0);
	}
}
