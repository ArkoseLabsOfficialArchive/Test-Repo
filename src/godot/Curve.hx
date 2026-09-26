package godot;

class Curve extends Resource {
	public var points:Array<Vector2>;

	public function new() {
		super();
		points = [];
	}

	public function add_point(point:Vector2):Void {
		var index:Int = 0;

		while (index < points.length && points[index].x < point.x) {
			index++;
		}

		points.insert(index, point.copy());
	}

	public function set_points(newPoints:Array<Vector2>):Void {
		points = newPoints.copy();
	}

	public function sample(t:Float):Float {
		if (points.length == 0) {
			return 0.0;
		}

		if (points.length == 1) {
			return points[0].y;
		}

		if (t <= points[0].x) {
			return points[0].y;
		}

		var last:Int = points.length - 1;

		if (t >= points[last].x) {
			return points[last].y;
		}

		var i:Int = 0;

		while (i < last) {
			var a:Vector2 = points[i];
			var b:Vector2 = points[i + 1];

			if (t >= a.x && t <= b.x) {
				var range:Float = b.x - a.x;

				if (range <= 0.0) {
					return a.y;
				}

				var localT:Float = (t - a.x) / range;
				return a.y + (b.y - a.y) * localT;
			}

			i++;
		}

		return points[last].y;
	}
}
