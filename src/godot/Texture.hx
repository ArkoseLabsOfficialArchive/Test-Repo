package godot;

class Texture extends Resource {
    public var width:Int;
    public var height:Int;

    public function new() {
        super();
        width = 0;
        height = 0;
    }

    public function get_size():Vector2 {
        return new Vector2(width, height);
    }
}