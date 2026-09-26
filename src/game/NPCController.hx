package game;

import godot.Node2D;

class NPCController extends Node2D {
    public var dialogue:String;

    public function new() {
        super();
        dialogue = "Hello, traveler.";
        add_user_signal("interacted");
    }

    public function interact():Void {
        emit_signal("interacted", [dialogue]);
    }
}