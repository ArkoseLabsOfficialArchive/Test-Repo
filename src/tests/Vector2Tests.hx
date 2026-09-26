package tests;

import godot.Vector2;

class Vector2Tests {
    public static function run():Void {
        var a:Vector2 = new Vector2(3, 4);
        TestRunner.assert(a.length() == 5.0, "Vector2.length");

        var n:Vector2 = a.normalized();
        TestRunner.assert(Math.abs(n.length() - 1.0) < 0.0001, "Vector2.normalized");

        var b:Vector2 = new Vector2(1, 0);
        TestRunner.assert(Math.abs(b.angle_to(new Vector2(0, 1)) - Math.PI / 2) < 0.0001, "Vector2.angle_to");

        var c:Vector2 = new Vector2(1, 1).linear_interpolate(new Vector2(3, 3), 0.5);
        TestRunner.assert(c.equals_approx(new Vector2(2, 2)), "Vector2.linear_interpolate");
    }
}