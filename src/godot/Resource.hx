package godot;

import godot.core.EngineError;
import godot.core.Log;

class Resource extends Reference {
    public var resourcePath:String;
    public var loaded:Bool;

    public function new() {
        super();
        resourcePath = "";
        loaded = false;
    }

    public function set_path(path:String):Void {
        resourcePath = path;
    }

    public function get_path():String {
        return resourcePath;
    }

    public function validate():Bool {
        return true;
    }

    override public function free():Void {
        if (loaded) {
            Log.debug("Resource", "Freeing loaded resource " + resourcePath);
        }
        super.free();
    }
}