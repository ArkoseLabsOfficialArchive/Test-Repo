package godot;

class Dictionary {
    var storage:Map<String, Dynamic>;

    public function new() {
        storage = new Map<String, Dynamic>();
    }

    public function set(key:String, value:Dynamic):Void {
        storage.set(key, value);
    }

    public function get(key:String):Null<Dynamic> {
        return storage.get(key);
    }

    public function has(key:String):Bool {
        return storage.exists(key);
    }

    public function erase(key:String):Bool {
        return storage.remove(key);
    }

    public function keys():Array<String> {
        var out:Array<String> = [];
        for (key in storage.keys()) {
            out.push(key);
        }
        return out;
    }

    public function size():Int {
        return keys().length;
    }

    public function clear():Void {
        storage = new Map<String, Dynamic>();
    }
}