package godot.rendering.openfl;

import godot.NinePatchRect;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class NinePatchRectRenderState extends RenderObjectState {
	public var background:Sprite;

	public var lastPatchLeft:Int;
	public var lastPatchTop:Int;
	public var lastPatchRight:Int;
	public var lastPatchBottom:Int;

	public var lastDrawCenter:Bool;

	public var lastAxisHorizontal:Int;
	public var lastAxisVertical:Int;

	public function new() {
		super();

		background = new Sprite();

		lastPatchLeft = -1;
		lastPatchTop = -1;
		lastPatchRight = -1;
		lastPatchBottom = -1;

		lastDrawCenter = true;

		lastAxisHorizontal = 0;
		lastAxisVertical = 0;
	}
}

class NinePatchRectRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(rect:NinePatchRect):RenderObjectState {
		var state:NinePatchRectRenderState = new NinePatchRectRenderState();

		state.displayObject = state.background;
		renderer.add_gui_object(state.background);

		return state;
	}

	public function update_if_dirty(rect:NinePatchRect, state:RenderObjectState):Void {
		var nineState:Null<NinePatchRectRenderState> = Std.instance(state, NinePatchRectRenderState);
		if (nineState == null) {
			return;
		}

		var textureId:Int = rect.texture != null ? rect.texture.instanceId : -1;

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;

		if (Math.isNaN(width))
			width = rect.rectSize.x;
		if (Math.isNaN(height))
			height = rect.rectSize.y;

		var needsUpdate:Bool = state.lastTextureId != textureId
			|| nineState.lastPatchLeft != rect.patchMarginLeft
			|| nineState.lastPatchTop != rect.patchMarginTop
			|| nineState.lastPatchRight != rect.patchMarginRight
			|| nineState.lastPatchBottom != rect.patchMarginBottom
			|| nineState.lastDrawCenter != rect.drawCenter
			|| nineState.lastAxisHorizontal != rect.axisStretchHorizontal
			|| nineState.lastAxisVertical != rect.axisStretchVertical
			|| nineState.lastWidth != width
			|| nineState.lastHeight != height
			|| rect.is_dirty(DirtyFlag.Texture)
			|| rect.is_dirty(DirtyFlag.Visual)
			|| rect.is_dirty(DirtyFlag.Layout);

		if (!needsUpdate) {
			return;
		}

		nineState.background.graphics.clear();

		var bitmapData:Null<BitmapData> = TextureHelper.get_native_bitmap(rect.texture);
		var sourceRect:Null<Rectangle> = TextureHelper.get_source_rect(rect.texture);

		if (bitmapData != null && sourceRect != null) {
			draw_nine_patch(nineState.background.graphics, bitmapData, sourceRect, width, height, rect.patchMarginLeft, rect.patchMarginTop,
				rect.patchMarginRight, rect.patchMarginBottom, rect.drawCenter, rect.axisStretchHorizontal, rect.axisStretchVertical);
		} else {
			nineState.background.graphics.beginFill(0xFF00FF, 0.25);
			nineState.background.graphics.drawRect(0.0, 0.0, width, height);
			nineState.background.graphics.endFill();
		}

		state.lastTextureId = textureId;

		nineState.lastPatchLeft = rect.patchMarginLeft;
		nineState.lastPatchTop = rect.patchMarginTop;
		nineState.lastPatchRight = rect.patchMarginRight;
		nineState.lastPatchBottom = rect.patchMarginBottom;

		nineState.lastDrawCenter = rect.drawCenter;

		nineState.lastAxisHorizontal = rect.axisStretchHorizontal;
		nineState.lastAxisVertical = rect.axisStretchVertical;

		nineState.lastWidth = width;
		nineState.lastHeight = height;

		rect.clear_dirty(DirtyFlag.Texture);
		rect.clear_dirty(DirtyFlag.Visual);
		rect.clear_dirty(DirtyFlag.Layout);
	}

	function draw_nine_patch(graphics:Graphics, bitmapData:BitmapData, sourceRect:Rectangle, destWidth:Float, destHeight:Float, marginLeft:Int, marginTop:Int,
			marginRight:Int, marginBottom:Int, drawCenter:Bool, axisHorizontal:Int, axisVertical:Int):Void {
		if (destWidth <= 0.0 || destHeight <= 0.0) {
			return;
		}

		var sourceWidth:Float = sourceRect.width;
		var sourceHeight:Float = sourceRect.height;

		if (sourceWidth <= 0.0 || sourceHeight <= 0.0) {
			return;
		}

		var srcLeft:Int = clamp_margin(marginLeft, Math.floor(sourceWidth * 0.5));
		var srcTop:Int = clamp_margin(marginTop, Math.floor(sourceHeight * 0.5));
		var srcRight:Int = clamp_margin(marginRight, Math.floor(sourceWidth * 0.5));
		var srcBottom:Int = clamp_margin(marginBottom, Math.floor(sourceHeight * 0.5));

		var dstLeft:Float = Math.min(marginLeft, destWidth * 0.5);
		var dstTop:Float = Math.min(marginTop, destHeight * 0.5);
		var dstRight:Float = Math.min(marginRight, destWidth * 0.5);
		var dstBottom:Float = Math.min(marginBottom, destHeight * 0.5);

		var sx:Float = sourceRect.x;
		var sy:Float = sourceRect.y;

		var centerSourceWidth:Float = sourceWidth - srcLeft - srcRight;
		var centerSourceHeight:Float = sourceHeight - srcTop - srcBottom;

		var centerDestWidth:Float = destWidth - dstLeft - dstRight;
		var centerDestHeight:Float = destHeight - dstTop - dstBottom;

		if (centerDestWidth < 0.0)
			centerDestWidth = 0.0;
		if (centerDestHeight < 0.0)
			centerDestHeight = 0.0;

		var tileHorizontal:Bool = axisHorizontal != 0;
		var tileVertical:Bool = axisVertical != 0;

		// Top-left
		draw_patch(graphics, bitmapData, sx, sy, srcLeft, srcTop, 0.0, 0.0, dstLeft, dstTop, false, false);

		// Top
		draw_patch(graphics, bitmapData, sx + srcLeft, sy, centerSourceWidth, srcTop, dstLeft, 0.0, centerDestWidth, dstTop, tileHorizontal, false);

		// Top-right
		draw_patch(graphics, bitmapData, sx + srcLeft + centerSourceWidth, sy, srcRight, srcTop, dstLeft + centerDestWidth, 0.0, dstRight, dstTop, false,
			false);

		// Left
		draw_patch(graphics, bitmapData, sx, sy + srcTop, srcLeft, centerSourceHeight, 0.0, dstTop, dstLeft, centerDestHeight, false, tileVertical);

		// Center
		if (drawCenter) {
			draw_patch(graphics, bitmapData, sx + srcLeft, sy + srcTop, centerSourceWidth, centerSourceHeight, dstLeft, dstTop, centerDestWidth,
				centerDestHeight, tileHorizontal, tileVertical);
		}

		// Right
		draw_patch(graphics, bitmapData, sx
			+ srcLeft
			+ centerSourceWidth, sy
			+ srcTop, srcRight, centerSourceHeight, dstLeft
			+ centerDestWidth, dstTop,
			dstRight, centerDestHeight, false, tileVertical);

		// Bottom-left
		draw_patch(graphics, bitmapData, sx, sy + srcTop + centerSourceHeight, srcLeft, srcBottom, 0.0, dstTop + centerDestHeight, dstLeft, dstBottom, false,
			false);

		// Bottom
		draw_patch(graphics, bitmapData, sx
			+ srcLeft, sy
			+ srcTop
			+ centerSourceHeight, centerSourceWidth, srcBottom, dstLeft, dstTop
			+ centerDestHeight,
			centerDestWidth, dstBottom, tileHorizontal, false);

		// Bottom-right
		draw_patch(graphics, bitmapData, sx
			+ srcLeft
			+ centerSourceWidth, sy
			+ srcTop
			+ centerSourceHeight, srcRight, srcBottom, dstLeft
			+ centerDestWidth,
			dstTop
			+ centerDestHeight, dstRight, dstBottom, false, false);
	}

	function draw_patch(graphics:Graphics, bitmapData:BitmapData, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, destX:Float,
			destY:Float, destWidth:Float, destHeight:Float, tileHorizontal:Bool, tileVertical:Bool):Void {
		if (sourceWidth <= 0.0 || sourceHeight <= 0.0) {
			return;
		}

		if (destWidth <= 0.0 || destHeight <= 0.0) {
			return;
		}

		if (!tileHorizontal && !tileVertical) {
			draw_patch_stretched(graphics, bitmapData, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight);

			return;
		}

		var y:Float = 0.0;

		while (y < destHeight) {
			var cellDestHeight:Float = tileVertical ? Math.min(sourceHeight, destHeight - y) : destHeight;
			var cellSourceHeight:Float = tileVertical ? sourceHeight * (cellDestHeight / sourceHeight) : sourceHeight;

			var x:Float = 0.0;

			while (x < destWidth) {
				var cellDestWidth:Float = tileHorizontal ? Math.min(sourceWidth, destWidth - x) : destWidth;
				var cellSourceWidth:Float = tileHorizontal ? sourceWidth * (cellDestWidth / sourceWidth) : sourceWidth;

				draw_patch_stretched(graphics, bitmapData, sourceX, sourceY, cellSourceWidth, cellSourceHeight, destX + x, destY + y, cellDestWidth,
					cellDestHeight);

				if (!tileHorizontal) {
					break;
				}

				x += cellDestWidth;
			}

			if (!tileVertical) {
				break;
			}

			y += cellDestHeight;
		}
	}

	function draw_patch_stretched(graphics:Graphics, bitmapData:BitmapData, sourceX:Float, sourceY:Float, sourceWidth:Float, sourceHeight:Float, destX:Float,
			destY:Float, destWidth:Float, destHeight:Float):Void {
		if (sourceWidth <= 0.0 || sourceHeight <= 0.0) {
			return;
		}

		if (destWidth <= 0.0 || destHeight <= 0.0) {
			return;
		}

		var matrix:Matrix = new Matrix();

		matrix.a = destWidth / sourceWidth;
		matrix.d = destHeight / sourceHeight;

		matrix.tx = destX - sourceX * matrix.a;
		matrix.ty = destY - sourceY * matrix.d;

		graphics.beginBitmapFill(bitmapData, matrix, false, false);
		graphics.drawRect(destX, destY, destWidth, destHeight);
		graphics.endFill();
	}

	function clamp_margin(value:Int, max:Int):Int {
		if (value < 0) {
			return 0;
		}

		if (value > max) {
			return max;
		}

		return value;
	}
}
