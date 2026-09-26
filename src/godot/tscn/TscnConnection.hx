package godot.tscn;

class TscnConnection {
    public var from:String;
    public var to:String;
    public var signal:String;
    public var method:String;

    public function new(from:String, to:String, signal:String, method:String) {
        this.from = from;
        this.to = to;
        this.signal = signal;
        this.method = method;
    }
}