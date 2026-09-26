package godot.rendering.openfl;

import godot.TextureRect;
import godot.DirtyFlag;
import openfl.display.Bitmap;

class TextureRectRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(rect:TextureRect):RenderObjectState {
		var state:RenderObjectState = new RenderObjectState();
		var bitmap:Bitmap = new Bitmap();
		state.displayObject = bitmap;
		renderer.add_gui_object(bitmap);
		return state;
	}

	public function update_if_dirty(rect:TextureRect, state:RenderObjectState):Void {
		var bitmap:Null<Bitmap> = Std.instance(state.displayObject, Bitmap);
		if (bitmap == null)
			return;

		// Advance animation frame if applicable
		var animChanged:Bool = TextureHelper.update_animated_texture(rect.texture, godot.EngineTime.delta);
		if (animChanged) {
			rect.mark_dirty(DirtyFlag.Texture);
		}

		if (rect.is_dirty(DirtyFlag.Texture)) {
			TextureHelper.apply_to_bitmap(bitmap, rect.texture);
			state.lastTextureId = rect.texture != null ? rect.texture.instanceId : -1;
			rect.clear_dirty(DirtyFlag.Texture);
		}

		if (rect.is_dirty(DirtyFlag.Layout)) {
			var width:Float = state.lastWidth;
			var height:Float = state.lastHeight;
			if (Math.isNaN(width))
				width = 0.0;
			if (Math.isNaN(height))
				height = 0.0;

			if (rect.expand) {
				if (bitmap.bitmapData != null && bitmap.bitmapData.width > 0 && bitmap.bitmapData.height > 0) {
					var scaleX:Float = width / bitmap.bitmapData.width;
					var scaleY:Float = height / bitmap.bitmapData.height;

					if (rect.stretchMode != 1) {
						var scale:Float = Math.min(scaleX, scaleY);
						scaleX = scale;
						scaleY = scale;
					}

					bitmap.scaleX = rect.flipH ? -scaleX : scaleX;
					bitmap.scaleY = rect.flipV ? -scaleY : scaleY;

					if (rect.stretchMode == 4 || rect.stretchMode == 6) {
						bitmap.x = (width - bitmap.bitmapData.width * bitmap.scaleX) * 0.5;
						bitmap.y = (height - bitmap.bitmapData.height * bitmap.scaleY) * 0.5;
					} else {
						bitmap.x = 0;
						bitmap.y = 0;
					}
				}
			} else {
				bitmap.scaleX = rect.flipH ? -1.0 : 1.0;
				bitmap.scaleY = rect.flipV ? -1.0 : 1.0;
				bitmap.x = 0;
				bitmap.y = 0;
			}
			rect.clear_dirty(DirtyFlag.Layout);
		}
	}
}
