package godot;

class AudioServer {
    public static var instance:AudioServer = new AudioServer();

    function new() {}

    public function get_bus_volume_db(bus:String):Float {
        return 0.0;
    }
}