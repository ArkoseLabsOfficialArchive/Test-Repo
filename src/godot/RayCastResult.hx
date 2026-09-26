package godot;

class RayCastResult {
    public var collided:Bool;
    public var position:Vector2;
    public var normal:Vector2;
    public var collider:Null<CollisionObject2D>;

    public function new() {
        collided = false;
        position = new Vector2();
        normal = new Vector2();
        collider = null;
    }
}