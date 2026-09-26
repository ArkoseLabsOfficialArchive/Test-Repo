package tests;

import godot.Transform2D;
import godot.Vector2;

class Transform2DTests {
    public static function run():Void {
        var t:Transform2D = Transform2D.from_rotation_translation_scale(
            Math.PI / 2.0,
            new Vector2(10, 20),
            new Vector2(1, 1)
        );

        var p:Vector2 = t.xform(new Vector2(1, 0));
        TestRunner.assert(Math.abs(p.x - 10.0) < 0.0001, "Transform2D.xform.x");
        TestRunner.assert(Math.abs(p.y - 21.0) < 0.0001, "Transform2D.xform.y");

        var inv:Transform2D = t.affine_inverse();
        var back:Vector2 = inv.xform(p);
        TestRunner.assert(back.equals_approx(new Vector2(1, 0)), "Transform2D.affine_inverse");
    }
}