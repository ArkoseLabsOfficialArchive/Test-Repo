package godot;

class RID {
    public var id:Int;

    public function new(id:Int = 0) {
        this.id = id;
    }

    public function is_valid():Bool {
        return id != 0;
    }

    public function equals(other:RID):Bool {
        return id == other.id;
    }
}