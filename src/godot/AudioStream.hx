package godot;

class AudioStream extends Resource {
    public var sound:Null<openfl.media.Sound>;

    public function new() {
        super();
        sound = null;
    }

    public function load_from_file(systemPath:String):Void {
        sound = new openfl.media.Sound();
        sound.load(new openfl.net.URLRequest(systemPath));
    }

    public function get_length():Float {
        return sound != null ? sound.length : 0.0;
    }
}