package godot.tscn;

class TscnSubResource {
    public var id:String;
    public var type:String;
    public var properties:Map<String, TscnValue>;

    public function new(id:String, type:String) {
        this.id = id;
        this.type = type;
        properties = new Map<String, TscnValue>();
    }
}