package godot;

class Transform2D {
    public var x:Vector2;
    public var y:Vector2;
    public var origin:Vector2;

    public function new(x:Vector2, y:Vector2, origin:Vector2) {
        this.x = x;
        this.y = y;
        this.origin = origin;
    }

    public static function identity():Transform2D {
        return new Transform2D(
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(0, 0)
        );
    }

    public static function from_rotation_translation_scale(
        rotation:Float,
        translation:Vector2,
        scale:Vector2
    ):Transform2D {
        var c:Float = Math.cos(rotation);
        var s:Float = Math.sin(rotation);

        return new Transform2D(
            new Vector2(c * scale.x, s * scale.x),
            new Vector2(-s * scale.y, c * scale.y),
            translation.copy()
        );
    }

    public function copy():Transform2D {
        return new Transform2D(x.copy(), y.copy(), origin.copy());
    }

    public function determinant():Float {
        return x.x * y.y - x.y * y.x;
    }

    public function affine_inverse():Transform2D {
        var det:Float = determinant();
        if (det == 0.0) {
            return identity();
        }

        var invDet:Float = 1.0 / det;

        var ix:Vector2 = new Vector2(y.y * invDet, -x.y * invDet);
        var iy:Vector2 = new Vector2(-y.x * invDet, x.x * invDet);

        var invOrigin:Vector2 = new Vector2(
            -(ix.x * origin.x + iy.x * origin.y),
            -(ix.y * origin.x + iy.y * origin.y)
        );

        return new Transform2D(ix, iy, invOrigin);
    }

    public function inverse():Transform2D {
        return affine_inverse();
    }

    public function basis_xform(v:Vector2):Vector2 {
        return new Vector2(
            x.x * v.x + y.x * v.y,
            x.y * v.x + y.y * v.y
        );
    }

    public function basis_xform_inv(v:Vector2):Vector2 {
        return new Vector2(
            x.x * v.x + x.y * v.y,
            y.x * v.x + y.y * v.y
        );
    }

    public function xform(v:Vector2):Vector2 {
        return new Vector2(
            x.x * v.x + y.x * v.y + origin.x,
            x.y * v.x + y.y * v.y + origin.y
        );
    }

    public function xform_inv(v:Vector2):Vector2 {
        var px:Float = v.x - origin.x;
        var py:Float = v.y - origin.y;
        return new Vector2(
            x.x * px + x.y * py,
            y.x * px + y.y * py
        );
    }

    public function translated(offset:Vector2):Transform2D {
        var out:Transform2D = copy();
        out.origin = out.origin.add(offset);
        return out;
    }

    public function scaled(scale:Vector2):Transform2D {
        var out:Transform2D = copy();
        out.x = out.x.scale(scale.x);
        out.y = out.y.scale(scale.y);
        out.origin = new Vector2(out.origin.x * scale.x, out.origin.y * scale.y);
        return out;
    }

    public function rotated(angle:Float):Transform2D {
        var rot:Transform2D = from_rotation_translation_scale(
            angle,
            new Vector2(0, 0),
            new Vector2(1, 1)
        );
        return multiply(rot);
    }

    public function multiply(other:Transform2D):Transform2D {
        return new Transform2D(
            basis_xform(other.x),
            basis_xform(other.y),
            xform(other.origin)
        );
    }

    public function get_rotation():Float {
        return Math.atan2(x.y, x.x);
    }

    public function get_scale():Vector2 {
        return new Vector2(x.length(), y.length());
    }

    public function toString():String {
        return "x=" + x.toString() + ", y=" + y.toString() + ", origin=" + origin.toString();
    }
}