package godot;

class Line2D extends Node2D {
    public var points:Array<Vector2>;
    public var width:Float;
    public var defaultColor:Color;

    public function new() {
        super();
        points = [];
        width = 2.0;
        defaultColor = Color.white();
    }
}