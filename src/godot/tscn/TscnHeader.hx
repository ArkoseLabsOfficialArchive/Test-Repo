package godot.tscn;

class TscnHeader {
    public var loadSteps:Int;
    public var format:Int;

    public function new(loadSteps:Int, format:Int) {
        this.loadSteps = loadSteps;
        this.format = format;
    }
}