package godot;

class ParticleData {
	public var active:Bool;
	public var position:Vector2;
	public var velocity:Vector2;
	public var life:Float;

	public function new() {
		active = false;
		position = new Vector2(0, 0);
		velocity = new Vector2(0, 0);
		life = 0.0;
	}

	public function reset():Void {
		active = false;
		position.set(0, 0);
		velocity.set(0, 0);
		life = 0.0;
	}
}
