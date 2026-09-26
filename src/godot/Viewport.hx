package godot;

class Viewport extends Node {
    public var size:Vector2;
    public var canvasTransform:Transform2D;

    public function new() {
        super();
        size = new Vector2(1280, 720);
        canvasTransform = Transform2D.identity();
    }

    public function get_visible_rect():Rect2 {
        return new Rect2(new Vector2(0, 0), size.copy());
    }

    public function set_canvas_transform(transform:Transform2D):Void {
        canvasTransform = transform;
    }

    public function get_canvas_transform():Transform2D {
        return canvasTransform;
    }
}