package godot;

class CollisionPolygon2D extends Node2D {
    public var polygon:Array<Vector2>;

    public function new() {
        super();
        polygon = [];
    }
}