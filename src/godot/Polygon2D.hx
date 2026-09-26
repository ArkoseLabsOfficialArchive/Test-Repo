package godot;

class Polygon2D extends Node2D {
    public var polygon:Array<Vector2>;
    public var color:Color;

    public function new() {
        super();
        polygon = [];
        color = Color.white();
    }
}