package godot;

class Area2D extends CollisionObject2D {
    public function new() {
        super();
        add_user_signal("body_entered");
        add_user_signal("body_exited");
        set_physics_process(true);
    }

    override public function _physics_process(delta:Float):Void {
        var bodies:Array<PhysicsBody2D> = Physics2DServer.instance.get_overlapping_bodies(this);
        for (body in bodies) {
            emit_signal("body_entered", [body]);
        }
    }
}