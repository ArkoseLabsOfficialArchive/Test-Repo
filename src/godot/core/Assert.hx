package godot.core;

class Assert {
    public static function that(condition:Bool, message:String):Void {
        if (!condition) {
            Log.fatal(new EngineError(
                "Core",
                "Assert",
                "that",
                message
            ));
        }
    }

    public static function notNull(value:Dynamic, message:String):Void {
        if (value == null) {
            Log.fatal(new EngineError(
                "Core",
                "Assert",
                "notNull",
                message
            ));
        }
    }
}u