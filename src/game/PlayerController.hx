package game;

import godot.KinematicBody2D;
import godot.Vector2;
import godot.Input;

class PlayerController extends KinematicBody2D {
    public var speed:Float;
    public var velocity:Vector2;
    public var health:Int;

    public function new() {
        super();
        speed = 220.0;
        velocity = new Vector2(0, 0);
        health = 100;
        set_physics_process(true);
        set_input_enabled(true);
    }

    override public function _physics_process(delta:Float):Void {
        var inputDir:Vector2 = new Vector2(0, 0);

        if (Input.instance.is_action_pressed("move_left")) {
            inputDir.x -= 1.0;
        }

        if (Input.instance.is_action_pressed("move_right")) {
            inputDir.x += 1.0;
        }

        if (Input.instance.is_action_pressed("move_up")) {
            inputDir.y -= 1.0;
        }

        if (Input.instance.is_action_pressed("move_down")) {
            inputDir.y += 1.0;
        }

        velocity = inputDir.normalized().scale(speed);
        move_and_slide(velocity, new Vector2(0, -1));
    }

    override public function _input(event:godot.InputEvent):Void {
        if (Input.instance.is_action_just_pressed("attack")) {
            attack();
        }
    }

    public function attack():Void {
        emit_signal("attacked", []);
    }

    public function take_damage(amount:Int):Void {
        health -= amount;
        if (health < 0) {
            health = 0;
        }
        emit_signal("health_changed", [health]);
    }
}