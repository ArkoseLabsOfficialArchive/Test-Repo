package godot.tscn;

class TscnExternalResource {
    public var id:String;
    public var path:String;
    public var type:String;

    public function new(id:String, path:String, type:String) {
        this.id = id;
        this.path = path;
        this.type = type;
    }
}