package godot;

class Color {
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;

	public function new(r:Float = 0.0, g:Float = 0.0, b:Float = 0.0, a:Float = 1.0) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public static function white():Color {
		return new Color(1, 1, 1, 1);
	}

	public static function black():Color {
		return new Color(0, 0, 0, 1);
	}

	public static function transparent():Color {
		return new Color(0, 0, 0, 0);
	}

	public static function from_rgba8(r:Int, g:Int, b:Int, a:Int):Color {
		return new Color(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
	}

	public function to_argb32():Int {
		var ai:Int = Math.round(a * 255);
		var ri:Int = Math.round(r * 255);
		var gi:Int = Math.round(g * 255);
		var bi:Int = Math.round(b * 255);
		return (ai << 24) | (ri << 16) | (gi << 8) | bi;
	}

	public function copy():Color {
		return new Color(r, g, b, a);
	}

	public function linear_interpolate(other:Color, t:Float):Color {
		return new Color(r + (other.r - r) * t, g + (other.g - g) * t, b + (other.b - b) * t, a + (other.a - a) * t);
	}

	public function equals(other:Color):Bool {
		return r == other.r && g == other.g && b == other.b && a == other.a;
	}
}
