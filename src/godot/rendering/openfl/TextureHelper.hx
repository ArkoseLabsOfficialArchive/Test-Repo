package godot.rendering.openfl;

import godot.Texture;
import godot.StreamTexture;
import godot.ImageTexture;
import godot.AtlasTexture;
import godot.GradientTexture;
import godot.GradientTexture2D;
import godot.CurveTexture;
import godot.AnimatedTexture;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class TextureHelper {
	public static function apply_to_bitmap(bitmap:Bitmap, texture:Null<Texture>):Void {
		if (texture == null) {
			bitmap.bitmapData = null;
			bitmap.scrollRect = null;
			return;
		}

		var animated:Null<AnimatedTexture> = Std.instance(texture, AnimatedTexture);
		if (animated != null) {
			apply_to_bitmap(bitmap, animated.get_current_texture());
			return;
		}

		var atlas:Null<AtlasTexture> = Std.instance(texture, AtlasTexture);
		if (atlas != null) {
			var baseBitmap:Null<BitmapData> = get_native_bitmap(atlas.atlas);

			if (baseBitmap == null) {
				bitmap.bitmapData = null;
				bitmap.scrollRect = null;
				return;
			}

			bitmap.bitmapData = baseBitmap;
			bitmap.scrollRect = new Rectangle(atlas.region.position.x, atlas.region.position.y, atlas.region.size.x, atlas.region.size.y);

			return;
		}

		var gradient:Null<GradientTexture> = Std.instance(texture, GradientTexture);
		if (gradient != null) {
			bitmap.bitmapData = gradient.get_bitmap_data();
			bitmap.scrollRect = null;
			return;
		}

		var gradient2D:Null<GradientTexture2D> = Std.instance(texture, GradientTexture2D);
		if (gradient2D != null) {
			bitmap.bitmapData = gradient2D.get_bitmap_data();
			bitmap.scrollRect = null;
			return;
		}

		var curveTexture:Null<CurveTexture> = Std.instance(texture, CurveTexture);
		if (curveTexture != null) {
			bitmap.bitmapData = curveTexture.get_bitmap_data();
			bitmap.scrollRect = null;
			return;
		}

		var nativeBitmap:Null<BitmapData> = get_native_bitmap(texture);
		bitmap.bitmapData = nativeBitmap;
		bitmap.scrollRect = null;
	}

	public static function get_native_bitmap(texture:Null<Texture>):Null<BitmapData> {
		if (texture == null) {
			return null;
		}

		var stream:Null<StreamTexture> = Std.instance(texture, StreamTexture);
		if (stream != null) {
			return stream.bitmap;
		}

		var image:Null<ImageTexture> = Std.instance(texture, ImageTexture);
		if (image != null) {
			return image.pixels;
		}

		var gradient:Null<GradientTexture> = Std.instance(texture, GradientTexture);
		if (gradient != null) {
			return gradient.get_bitmap_data();
		}

		var gradient2D:Null<GradientTexture2D> = Std.instance(texture, GradientTexture2D);
		if (gradient2D != null) {
			return gradient2D.get_bitmap_data();
		}

		var curveTexture:Null<CurveTexture> = Std.instance(texture, CurveTexture);
		if (curveTexture != null) {
			return curveTexture.get_bitmap_data();
		}

		var atlas:Null<AtlasTexture> = Std.instance(texture, AtlasTexture);
		if (atlas != null) {
			return get_native_bitmap(atlas.atlas);
		}

		var animated:Null<AnimatedTexture> = Std.instance(texture, AnimatedTexture);
		if (animated != null) {
			return get_native_bitmap(animated.get_current_texture());
		}

		return null;
	}

	public static function update_animated_texture(texture:Null<Texture>, delta:Float):Bool {
		var animated:Null<AnimatedTexture> = Std.instance(texture, AnimatedTexture);
		if (animated != null) {
			return animated.update(delta);
		}
		return false;
	}

	public static function get_source_rect(texture:Null<Texture>):Null<Rectangle> {
		if (texture == null) {
			return null;
		}

		var atlas:Null<AtlasTexture> = Std.instance(texture, AtlasTexture);
		if (atlas != null) {
			return new Rectangle(atlas.region.position.x, atlas.region.position.y, atlas.region.size.x, atlas.region.size.y);
		}

		var bitmap:Null<BitmapData> = get_native_bitmap(texture);
		if (bitmap == null) {
			return null;
		}

		return new Rectangle(0, 0, bitmap.width, bitmap.height);
	}
}
