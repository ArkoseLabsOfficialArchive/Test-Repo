package godot;

class Vector3 {
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public function new(x:Float = 0.0, y:Float = 0.0, z:Float = 0.0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function copy():Vector3 {
		return new Vector3(x, y, z);
	}

	public function add(other:Vector3):Vector3 {
		return new Vector3(x + other.x, y + other.y, z + other.z);
	}

	public function subtract(other:Vector3):Vector3 {
		return new Vector3(x - other.x, y - other.y, z - other.z);
	}

	public function scale(s:Float):Vector3 {
		return new Vector3(x * s, y * s, z * s);
	}

	public function length():Float {
		return Math.sqrt(x * x + y * y + z * z);
	}

	public function normalized():Vector3 {
		var len:Float = length();

		if (len == 0.0) {
			return new Vector3(0, 0, 0);
		}

		return new Vector3(x / len, y / len, z / len);
	}
}
