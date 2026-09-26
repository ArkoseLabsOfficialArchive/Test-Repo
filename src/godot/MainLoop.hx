package godot;

class MainLoop extends Object {
    public function _initialize():Void {}
    public function _process(delta:Float):Bool {
        return false;
    }
    public function _physics_process(delta:Float):Bool {
        return false;
    }
    public function _finalize():Void {}
}