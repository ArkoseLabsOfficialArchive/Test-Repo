package godot.rendering.openfl;

import godot.AnimatedSprite;
import godot.Texture;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.display.Bitmap;

class AnimatedSpriteRenderState extends RenderObjectState {
	public var container:Sprite;
	public var bitmap:Bitmap;

	public function new() {
		super();

		container = new Sprite();
		bitmap = new Bitmap();

		container.addChild(bitmap);
	}
}

class AnimatedSpriteRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(sprite:AnimatedSprite):RenderObjectState {
		var state:AnimatedSpriteRenderState = new AnimatedSpriteRenderState();

		state.displayObject = state.container;
		renderer.add_world_object(state.container);

		return state;
	}

	public function update_if_dirty(sprite:AnimatedSprite, state:RenderObjectState):Void {
		var animatedState:Null<AnimatedSpriteRenderState> = Std.instance(state, AnimatedSpriteRenderState);
		if (animatedState == null) {
			return;
		}

		var bitmap:Bitmap = animatedState.bitmap;

		var needsTextureUpdate:Bool = sprite.is_dirty(DirtyFlag.Frame) || sprite.is_dirty(DirtyFlag.Texture) || sprite.is_dirty(DirtyFlag.Visual);

		if (!needsTextureUpdate) {
			return;
		}

		var texture:Null<Texture> = sprite.get_current_texture();
		var textureId:Int = texture != null ? texture.instanceId : -1;

		if (state.lastTextureId != textureId || state.lastFrame != sprite.frame) {
			state.lastTextureId = textureId;
			state.lastFrame = sprite.frame;

			TextureHelper.apply_to_bitmap(bitmap, texture);
		}

		var drawWidth:Float = 0.0;
		var drawHeight:Float = 0.0;

		if (bitmap.scrollRect != null) {
			drawWidth = bitmap.scrollRect.width;
			drawHeight = bitmap.scrollRect.height;
		} else if (bitmap.bitmapData != null) {
			drawWidth = bitmap.bitmapData.width;
			drawHeight = bitmap.bitmapData.height;
		}

		var baseX:Float = 0.0;
		var baseY:Float = 0.0;

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

		sprite.clear_dirty(DirtyFlag.Frame);
		sprite.clear_dirty(DirtyFlag.Texture);
		sprite.clear_dirty(DirtyFlag.Visual);
	}
}
