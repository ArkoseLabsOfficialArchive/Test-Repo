package godot;

class Curve2D extends Resource {
	public var points:Array<Vector2>;

	public function new() {
		super();
		points = [];
	}

	public function add_point(pos:Vector2):Void {
		points.push(pos.copy());
	}

	public function get_length():Float {
		var len = 0.0;
		for (i in 0...points.length - 1)
			len += points[i].distance_to(points[i + 1]);
		return len;
	}

	public function sample(offset:Float):Vector2 {
		if (points.length == 0)
			return new Vector2();
		if (points.length == 1)
			return points[0].copy();

		var totalLen = get_length();
		var targetDist = offset * totalLen;
		var currentDist = 0.0;

		for (i in 0...points.length - 1) {
			var segLen = points[i].distance_to(points[i + 1]);
			if (currentDist + segLen >= targetDist) {
				var t = (targetDist - currentDist) / segLen;
				return points[i].linear_interpolate(points[i + 1], t);
			}
			currentDist += segLen;
		}
		return points[points.length - 1].copy();
	}
}
