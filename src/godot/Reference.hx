package godot;

class Reference extends Object {
    public var referenceCount:Int;

    public function new() {
        super();
        referenceCount = 0;
    }

    public function reference():Bool {
        referenceCount++;
        return true;
    }

    public function unreference():Bool {
        referenceCount--;
        if (referenceCount <= 0) {
            free();
            return true;
        }
        return false;
    }

    public function is_referenced():Bool {
        return referenceCount > 0;
    }
}