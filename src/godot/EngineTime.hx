package godot;

class EngineTime {
    public static var delta:Float = 0.0;
    public static var physics_delta:Float = 1.0 / 60.0;
    public static var elapsed:Float = 0.0;
    public static var frame:Int = 0;

    public static function update(newDelta:Float):Void {
        delta = newDelta;
        elapsed += newDelta;
        frame++;
    }
}