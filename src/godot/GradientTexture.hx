package godot;

import openfl.display.BitmapData;

class GradientTexture extends Texture {
	public var gradient:Null<Gradient>;
	public var resolution:Int;

	var bitmap:Null<BitmapData>;
	var dirty:Bool;

	public function new() {
		super();

		gradient = new Gradient();
		resolution = 256;

		width = resolution;
		height = 1;

		bitmap = null;
		dirty = true;
	}

	public function mark_dirty():Void {
		dirty = true;
	}

	public function get_bitmap_data():Null<BitmapData> {
		if (dirty || bitmap == null) {
			bake();
		}

		return bitmap;
	}

	function bake():Void {
		var w:Int = resolution > 0 ? resolution : 1;

		width = w;
		height = 1;

		bitmap = new BitmapData(w, 1, true, 0x00000000);

		var actualGradient:Gradient = gradient != null ? gradient : new Gradient();

		for (x in 0...w) {
			var t:Float = w <= 1 ? 0.0 : x / (w - 1);
			var color:Color = actualGradient.sample(t);
			bitmap.setPixel32(x, 0, color.to_argb32());
		}

		dirty = false;
	}
}
