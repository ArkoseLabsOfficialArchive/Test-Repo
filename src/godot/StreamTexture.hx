package godot;

import godot.core.EngineError;
import godot.core.Log;

class StreamTexture extends Texture {
    public var bitmap:Null<openfl.display.BitmapData>;

    public function new() {
        super();
        bitmap = null;
    }

    public function load_from_file(systemPath:String):Void {
        try {
            var bytes:openfl.utils.ByteArray = openfl.utils.ByteArray.fromBytes(sys.io.File.getBytes(systemPath));
            bitmap = openfl.display.BitmapData.fromBytes(bytes);
            if (bitmap != null) {
                width = bitmap.width;
                height = bitmap.height;
            }
        } catch (e:Dynamic) {
            Log.fatal(new EngineError(
                "Resource",
                "StreamTexture",
                "load_from_file",
                "Failed to load texture: " + Std.string(e),
                null,
                resourcePath,
                null
            ));
        }
    }

    public function get_bitmap_data():Null<openfl.display.BitmapData> {
        return bitmap;
    }
}