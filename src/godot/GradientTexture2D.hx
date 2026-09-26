package godot;

import openfl.display.BitmapData;

class GradientTexture2D extends Texture {
	public var gradient:Null<Gradient>;
	public var fillFrom:Vector2;
	public var fillTo:Vector2;

	var bitmap:Null<BitmapData>;
	var dirty:Bool;

	public function new() {
		super();

		gradient = new Gradient();
		fillFrom = new Vector2(0.0, 0.0);
		fillTo = new Vector2(1.0, 0.0);

		width = 256;
		height = 256;

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
		var w:Int = width > 0 ? width : 1;
		var h:Int = height > 0 ? height : 1;

		bitmap = new BitmapData(w, h, true, 0x00000000);

		var actualGradient:Gradient = gradient != null ? gradient : new Gradient();

		var vector:Vector2 = fillTo.subtract(fillFrom);
		var denominator:Float = vector.dot(vector);

		for (y in 0...h) {
			for (x in 0...w) {
				var px:Float = w <= 1 ? 0.0 : x / (w - 1);
				var py:Float = h <= 1 ? 0.0 : y / (h - 1);

				var p:Vector2 = new Vector2(px, py);

				var t:Float = 0.0;

				if (denominator > 0.0) {
					t = p.subtract(fillFrom).dot(vector) / denominator;
				}

				if (t < 0.0)
					t = 0.0;
				if (t > 1.0)
					t = 1.0;

				var color:Color = actualGradient.sample(t);
				bitmap.setPixel32(x, y, color.to_argb32());
			}
		}

		dirty = false;
	}
}
