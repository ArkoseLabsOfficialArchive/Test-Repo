package godot.rendering.openfl;

import godot.TextureProgress;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;

class TextureProgressRenderState extends RenderObjectState {
	public var container:Sprite;
	public var underBitmap:Bitmap;
	public var progressBitmap:Bitmap;

	public var lastUnderTextureId:Int;
	public var lastProgressTextureId:Int;
	public var lastRatio:Float;

	public function new() {
		super();

		container = new Sprite();
		underBitmap = new Bitmap();
		progressBitmap = new Bitmap();

		lastUnderTextureId = -1;
		lastProgressTextureId = -1;
		lastRatio = Math.NaN;
	}
}

class TextureProgressRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(bar:TextureProgress):RenderObjectState {
		var state:TextureProgressRenderState = new TextureProgressRenderState();

		state.container.addChild(state.underBitmap);
		state.container.addChild(state.progressBitmap);

		state.displayObject = state.container;
		renderer.add_gui_object(state.container);

		return state;
	}

	public function update_if_dirty(bar:TextureProgress, state:RenderObjectState):Void {
		var barState:Null<TextureProgressRenderState> = Std.instance(state, TextureProgressRenderState);
		if (barState == null) {
			return;
		}

		var ratio:Float = bar.get_ratio();

		var underTextureId:Int = bar.textureUnder != null ? bar.textureUnder.instanceId : -1;
		var progressTextureId:Int = bar.textureProgress != null ? bar.textureProgress.instanceId : -1;

		var needsUpdate:Bool = barState.lastUnderTextureId != underTextureId
			|| barState.lastProgressTextureId != progressTextureId
			|| barState.lastRatio != ratio
			|| barState.lastWidth != bar.rectSize.x
			|| barState.lastHeight != bar.rectSize.y
			|| bar.is_dirty(DirtyFlag.Texture)
			|| bar.is_dirty(DirtyFlag.Visual)
			|| bar.is_dirty(DirtyFlag.Layout);

		if (!needsUpdate) {
			return;
		}

		if (barState.lastUnderTextureId != underTextureId) {
			TextureHelper.apply_to_bitmap(barState.underBitmap, bar.textureUnder);
			barState.lastUnderTextureId = underTextureId;
		}

		if (barState.lastProgressTextureId != progressTextureId) {
			TextureHelper.apply_to_bitmap(barState.progressBitmap, bar.textureProgress);
			barState.lastProgressTextureId = progressTextureId;
		}

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;

		if (Math.isNaN(width))
			width = 0.0;
		if (Math.isNaN(height))
			height = 0.0;

		if (barState.underBitmap.bitmapData != null) {
			barState.underBitmap.scaleX = width / barState.underBitmap.bitmapData.width;
			barState.underBitmap.scaleY = height / barState.underBitmap.bitmapData.height;
		}

		if (barState.progressBitmap.bitmapData != null) {
			var nativeWidth:Int = barState.progressBitmap.bitmapData.width;
			var nativeHeight:Int = barState.progressBitmap.bitmapData.height;

			var sourceRect:Null<Rectangle> = TextureHelper.get_source_rect(bar.textureProgress);

			var sourceX:Float = 0.0;
			var sourceY:Float = 0.0;
			var sourceWidth:Float = nativeWidth;
			var sourceHeight:Float = nativeHeight;

			if (sourceRect != null) {
				sourceX = sourceRect.x;
				sourceY = sourceRect.y;
				sourceWidth = sourceRect.width;
				sourceHeight = sourceRect.height;
			}

			var visibleSourceWidth:Float = sourceWidth * ratio;

			if (visibleSourceWidth <= 0.0) {
				barState.progressBitmap.visible = false;
			} else {
				barState.progressBitmap.visible = true;

				barState.progressBitmap.scrollRect = new Rectangle(sourceX, sourceY, visibleSourceWidth, sourceHeight);

				barState.progressBitmap.scaleX = width / sourceWidth;
				barState.progressBitmap.scaleY = height / sourceHeight;
			}
		} else {
			barState.progressBitmap.visible = false;
		}

		barState.lastRatio = ratio;
		barState.lastWidth = bar.rectSize.x;
		barState.lastHeight = bar.rectSize.y;

		bar.clear_dirty(DirtyFlag.Texture);
		bar.clear_dirty(DirtyFlag.Visual);
		bar.clear_dirty(DirtyFlag.Layout);
	}
}
