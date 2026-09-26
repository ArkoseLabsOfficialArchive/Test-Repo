package godot;

class ImageTexture extends Texture {
	public var pixels:Null<openfl.display.BitmapData>;

	public function new() {
		super();
		pixels = null;
	}

	public function create(w:Int, h:Int, color:Color):Void {
		width = w;
		height = h;
		pixels = new openfl.display.BitmapData(w, h, true, color.to_argb32());
	}

	public function get_bitmap_data():Null<openfl.display.BitmapData> {
		return pixels;
	}
}
