package godot;

class PoolVector2Array {
    public var values:Array<Vector2>;

    public function new(values:Array<Vector2> = null) {
        this.values = values != null ? values : [];
    }

    public function append(value:Vector2):Void {
        values.push(value);
    }

    public function size():Int {
        return values.length;
    }

    public function get(index:Int):Null<Vector2> {
        if (index < 0 || index >= values.length) {
            return null;
        }
        return values[index];
    }
}