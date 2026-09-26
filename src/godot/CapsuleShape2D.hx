package godot;

class CapsuleShape2D extends Shape2D {
	public var radius:Float;
	public var height:Float;

	public function new(radius:Float = 10.0, height:Float = 20.0) {
		super();

		this.radius = radius;
		this.height = height;
	}

	override public function get_rect():Rect2 {
		var totalHeight:Float = height + radius * 2.0;

		return Rect2.from_xywh(-radius, -totalHeight * 0.5, radius * 2.0, totalHeight);
	}
}
