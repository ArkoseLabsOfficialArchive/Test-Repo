package;

import godot.Node2D;
import godot.Vector2;

class Main extends openfl.display.Sprite {
    public function new() {
        super();

        godot.Engine.initialize(openfl.Lib.current.stage);

        godot.Input.instance.add_action_binding(new godot.Input.InputActionBinding("move_left", 65));
        godot.Input.instance.add_action_binding(new godot.Input.InputActionBinding("move_right", 68));
        godot.Input.instance.add_action_binding(new godot.Input.InputActionBinding("move_up", 87));
        godot.Input.instance.add_action_binding(new godot.Input.InputActionBinding("move_down", 83));
        godot.Input.instance.add_action_binding(new godot.Input.InputActionBinding("attack", 70));
        godot.Input.instance.add_action_binding(new godot.Input.InputActionBinding("pause", 27));

        godot.Engine.load_main_scene("res://lily.tscn");
        var root:Node2D = godot.Engine.mainSceneTree.root.get_node("Ch1_Home_2F_Bedroom_A");
        root.scale = new Vector2(-1, 1);
        root.position.x += 300;

        //tests.RunAllTests.main();
    }
}