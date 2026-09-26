package godot;

class GodotArray {
    public var items:Array<Dynamic>;

    public function new(items:Array<Dynamic> = null) {
        this.items = items != null ? items : [];
    }

    public function size():Int {
        return items.length;
    }

    public function push(value:Dynamic):Void {
        items.push(value);
    }

    public function pop():Null<Dynamic> {
        return items.pop();
    }

    public function get(index:Int):Null<Dynamic> {
        if (index < 0 || index >= items.length) {
            return null;
        }
        return items[index];
    }

    public function set(index:Int, value:Dynamic):Void {
        if (index < 0 || index >= items.length) {
            return;
        }
        items[index] = value;
    }

    public function clear():Void {
        items = [];
    }
}