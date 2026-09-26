package godot;

class VisualServer {
    public static var instance:Null<VisualServer> = null;

    public function new() {}

    public function register_canvas_item(item:CanvasItem):Void {}
    public function unregister_canvas_item(item:CanvasItem):Void {}
    public function synchronize():Void {}
}