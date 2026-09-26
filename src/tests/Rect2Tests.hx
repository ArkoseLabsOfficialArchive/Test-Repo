package tests;

import godot.Rect2;
import godot.Vector2;

class Rect2Tests {
    public static function run():Void {
        var r:Rect2 = Rect2.from_xywh(0, 0, 10, 10);
        TestRunner.assert(r.has_point(new Vector2(5, 5)), "Rect2.has_point inside");
        TestRunner.assert(!r.has_point(new Vector2(15, 15)), "Rect2.has_point outside");

        var r2:Rect2 = Rect2.from_xywh(5, 5, 10, 10);
        TestRunner.assert(r.intersects(r2), "Rect2.intersects");

        var inter:Null<Rect2> = r.intersection(r2);
        TestRunner.assert(inter != null, "Rect2.intersection not null");
    }
}