package godot.rendering.openfl;

import godot.Sprite;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;

class SpriteRenderState extends RenderObjectState {
	public var container:Sprite;
	public var bitmap:Bitmap;

	public function new() {
		super();

		container = new Sprite();
		bitmap = new Bitmap();

		container.addChild(bitmap);
	}
}

class SpriteRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(sprite:godot.Sprite):RenderObjectState {
		var state:SpriteRenderState = new SpriteRenderState();

		state.displayObject = state.container;
		renderer.add_world_object(state.container);

		return state;
	}

	public function update_if_dirty(sprite:godot.Sprite, state:RenderObjectState):Void {
		var spriteState:Null<SpriteRenderState> = Std.instance(state, SpriteRenderState);
		if (spriteState == null) {
			return;
		}

		var bitmap:Bitmap = spriteState.bitmap;

		if (sprite.is_dirty(DirtyFlag.Texture)) {
			update_texture(sprite, bitmap, state);
			sprite.clear_dirty(DirtyFlag.Texture);
			sprite.mark_dirty(DirtyFlag.Frame);
		}

		if (sprite.is_dirty(DirtyFlag.Frame)) {
			update_frame(sprite, bitmap);
			sprite.clear_dirty(DirtyFlag.Frame);
			sprite.mark_dirty(DirtyFlag.Visual);
		}

		if (sprite.is_dirty(DirtyFlag.Visual)) {
			update_visual(sprite, bitmap);
			sprite.clear_dirty(DirtyFlag.Visual);
		}
	}

	function update_texture(sprite:godot.Sprite, bitmap:Bitmap, state:RenderObjectState):Void {
		var textureId:Int = sprite.texture != null ? sprite.texture.instanceId : -1;

		if (state.lastTextureId == textureId) {
			return;
		}

		state.lastTextureId = textureId;
		TextureHelper.apply_to_bitmap(bitmap, sprite.texture);
	}

	function update_frame(sprite:godot.Sprite, bitmap:Bitmap):Void {
		if (sprite.hframes <= 1 && sprite.vframes <= 1) {
			TextureHelper.apply_to_bitmap(bitmap, sprite.texture);
			return;
		}

		if (bitmap.bitmapData == null) {
			return;
		}

		var sourceRect:Null<Rectangle> = TextureHelper.get_source_rect(sprite.texture);
		if (sourceRect == null) {
			return;
		}

		var hframes:Int = sprite.hframes < 1 ? 1 : sprite.hframes;
		var vframes:Int = sprite.vframes < 1 ? 1 : sprite.vframes;

		var frameWidth:Float = sourceRect.width / hframes;
		var frameHeight:Float = sourceRect.height / vframes;

		var frameCoords:godot.Vector2 = sprite.get_frame_coords();

		bitmap.scrollRect = new Rectangle(sourceRect.x + frameCoords.x * frameWidth, sourceRect.y + frameCoords.y * frameHeight, frameWidth, frameHeight);
	}

	function update_visual(sprite:godot.Sprite, bitmap:Bitmap):Void {
		var drawWidth:Float = 0.0;
		var drawHeight:Float = 0.0;

		if (bitmap.scrollRect != null) {
			drawWidth = bitmap.scrollRect.width;
			drawHeight = bitmap.scrollRect.height;
		} else if (bitmap.bitmapData != null) {
			drawWidth = bitmap.bitmapData.width;
			drawHeight = bitmap.bitmapData.height;
		}

		var baseX:Float = sprite.offset.x;
		var baseY:Float = sprite.offset.y;

		if (sprite.centered) {
			baseX -= drawWidth * 0.5;
			baseY -= drawHeight * 0.5;
		}

		if (sprite.flipH) {
			bitmap.scaleX = -1.0;
			bitmap.x = baseX + drawWidth;
		} else {
			bitmap.scaleX = 1.0;
			bitmap.x = baseX;
		}

		if (sprite.flipV) {
			bitmap.scaleY = -1.0;
			bitmap.y = baseY + drawHeight;
		} else {
			bitmap.scaleY = 1.0;
			bitmap.y = baseY;
		}
	}
}
