package tests;

import godot.NodePath;

class NodePathTests {
    public static function run():Void {
        var path:NodePath = new NodePath("Player/Sprite");
        TestRunner.assert(path.get_part_count() == 2, "NodePath part count");
        TestRunner.assert(path.get_part(0) == "Player", "NodePath part 0");
        TestRunner.assert(path.get_part(1) == "Sprite", "NodePath part 1");

        var abs:NodePath = new NodePath("/Root/Main");
        TestRunner.assert(abs.is_absolute(), "NodePath absolute");
    }
}