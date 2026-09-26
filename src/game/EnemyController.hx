package game;

import godot.KinematicBody2D;
import godot.Vector2;

class EnemyController extends KinematicBody2D {
    public var speed:Float;
    public var health:Int;
    public var target:Null<Vector2>;

    public function new() {
        super();
        speed = 120.0;
        health = 40;
        target = null;
        set_physics_process(true);
    }

    override public function _physics_process(delta:Float):Void {
        if (target == null) {
            return;
        }

        var dir:Vector2 = target.subtract(get_global_position());
        if (dir.length() < 8.0) {
            return;
        }

        var velocity:Vector2 = dir.normalized().scale(speed);
        move_and_slide(velocity, new Vector2(0, -1));
    }

    public function take_damage(amount:Int):Void {
        health -= amount;
        if (health <= 0) {
            die();
        }
    }

    public function die():Void {
        emit_signal("died", []);
        queue_free();
    }
}