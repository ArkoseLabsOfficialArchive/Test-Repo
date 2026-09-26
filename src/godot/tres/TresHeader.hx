package godot.tres;

class TresHeader {
    public var type:String;
    public var loadSteps:Int;
    public var format:Int;

    public function new(type:String, loadSteps:Int, format:Int) {
        this.type = type;
        this.loadSteps = loadSteps;
        this.format = format;
    }
}