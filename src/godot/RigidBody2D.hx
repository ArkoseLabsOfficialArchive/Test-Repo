package godot;

class RigidBody2D extends PhysicsBody2D {
    public var linearVelocity:Vector2;
    public var gravityScale:Float;

    public function new() {
        super();
        linearVelocity = new Vector2(0, 0);
        gravityScale = 1.0;
        set_physics_process(true);
    }

    override public function _physics_process(delta:Float):Void {
        var gravity:Vector2 = new Vector2(0, 980.0 * gravityScale);
        linearVelocity = linearVelocity.add(gravity.scale(delta));
        set_position(get_position().add(linearVelocity.scale(delta)));
    }
}