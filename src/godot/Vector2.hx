package godot;

class Vector2 {
    public var x:Float;
    public var y:Float;

    public function new(x:Float = 0.0, y:Float = 0.0) {
        this.x = x;
        this.y = y;
    }

    public static function zero():Vector2 {
        return new Vector2(0, 0);
    }

    public static function one():Vector2 {
        return new Vector2(1, 1);
    }

    public function set(x:Float, y:Float):Void {
        this.x = x;
        this.y = y;
    }

    public function copy():Vector2 {
        return new Vector2(x, y);
    }

    public function add(other:Vector2):Vector2 {
        return new Vector2(x + other.x, y + other.y);
    }

    public function subtract(other:Vector2):Vector2 {
        return new Vector2(x - other.x, y - other.y);
    }

    public function multiply(other:Vector2):Vector2 {
        return new Vector2(x * other.x, y * other.y);
    }

    public function scale(s:Float):Vector2 {
        return new Vector2(x * s, y * s);
    }

    public function length():Float {
        return Math.sqrt(x * x + y * y);
    }

    public function length_squared():Float {
        return x * x + y * y;
    }

    public function normalized():Vector2 {
        var len:Float = length();
        if (len == 0.0) {
            return new Vector2(0, 0);
        }
        return new Vector2(x / len, y / len);
    }

    public function distance_to(other:Vector2):Float {
        var dx:Float = x - other.x;
        var dy:Float = y - other.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    public function distance_squared_to(other:Vector2):Float {
        var dx:Float = x - other.x;
        var dy:Float = y - other.y;
        return dx * dx + dy * dy;
    }

    public function dot(other:Vector2):Float {
        return x * other.x + y * other.y;
    }

    public function cross(other:Vector2):Float {
        return x * other.y - y * other.x;
    }

    public function angle():Float {
        return Math.atan2(y, x);
    }

    public function angle_to(other:Vector2):Float {
        return Math.atan2(cross(other), dot(other));
    }

    public function rotated(angle:Float):Vector2 {
        var c:Float = Math.cos(angle);
        var s:Float = Math.sin(angle);
        return new Vector2(
            x * c - y * s,
            x * s + y * c
        );
    }

    public function linear_interpolate(other:Vector2, t:Float):Vector2 {
        return new Vector2(
            x + (other.x - x) * t,
            y + (other.y - y) * t
        );
    }

    public function clamped(maxLength:Float):Vector2 {
        var len:Float = length();
        if (len == 0.0) {
            return new Vector2(0, 0);
        }
        if (len <= maxLength) {
            return copy();
        }
        return scale(maxLength / len);
    }

    public function abs():Vector2 {
        return new Vector2(Math.abs(x), Math.abs(y));
    }

    public function floor():Vector2 {
        return new Vector2(Math.floor(x), Math.floor(y));
    }

    public function ceil():Vector2 {
        return new Vector2(Math.ceil(x), Math.ceil(y));
    }

    public function round():Vector2 {
        return new Vector2(Math.round(x), Math.round(y));
    }

    public function tangent():Vector2 {
        return new Vector2(y, -x);
    }

    public function is_zero_approx():Bool {
        return Math.abs(x) < 0.00001 && Math.abs(y) < 0.00001;
    }

    public function equals(other:Vector2):Bool {
        return x == other.x && y == other.y;
    }

    public function equals_approx(other:Vector2):Bool {
        return Math.abs(x - other.x) < 0.00001 && Math.abs(y - other.y) < 0.00001;
    }

    public function toString():String {
        return "(" + x + ", " + y + ")";
    }
}