package godot;

class RayCast2D extends Node2D {
    public var enabled:Bool;
    public var castTo:Vector2;
    public var collisionMask:Int;
    
    var result:RayCastResult;

    public function new() {
        super();
        enabled = true;
        castTo = new Vector2(0, 50);
        collisionMask = 1;
        result = new RayCastResult();
        set_physics_process(true);
    }

    override public function _physics_process(delta:Float):Void {
        if (!enabled) return;
        var from = get_global_position();
        var to = get_global_transform().xform(castTo);
        result = Physics2DServer.instance.raycast(from, to, collisionMask);
    }

    public function is_colliding():Bool { return result.collided; }
    public function get_collision_point():Vector2 { return result.position.copy(); }
    public function get_collision_normal():Vector2 { return result.normal.copy(); }
    public function get_collider():Null<CollisionObject2D> { return result.collider; }
}