package godot.rendering.openfl;

import godot.TextureButton;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.display.Bitmap;

class TextureButtonRenderState extends RenderObjectState {
	public var background:Sprite;
	public var bitmap:Bitmap;

	public var lastPressed:Bool;
	public var lastHovered:Bool;
	public var lastDisabled:Bool;

	public function new() {
		super();

		background = new Sprite();
		bitmap = new Bitmap();

		lastPressed = false;
		lastHovered = false;
		lastDisabled = false;
	}
}

class TextureButtonRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(button:TextureButton):RenderObjectState {
		var state:TextureButtonRenderState = new TextureButtonRenderState();
		var container:Sprite = new Sprite();

		container.addChild(state.background);
		container.addChild(state.bitmap);

		state.displayObject = container;
		renderer.add_gui_object(container);

		return state;
	}

	public function update_if_dirty(button:TextureButton, state:RenderObjectState):Void {
		var buttonState:Null<TextureButtonRenderState> = Std.instance(state, TextureButtonRenderState);
		if (buttonState == null) {
			return;
		}

		var texture:Null<godot.Texture> = button.get_current_texture();
		var textureId:Int = texture != null ? texture.instanceId : -1;

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;

		if (Math.isNaN(width))
			width = 0.0;
		if (Math.isNaN(height))
			height = 0.0;

		var needsUpdate:Bool = state.lastTextureId != textureId
			|| buttonState.lastPressed != button.pressed
			|| buttonState.lastHovered != button.hovered
			|| buttonState.lastDisabled != button.disabled
			|| button.is_dirty(DirtyFlag.Texture)
			|| button.is_dirty(DirtyFlag.Visual)
			|| button.is_dirty(DirtyFlag.Layout);

		if (!needsUpdate) {
			return;
		}

		if (texture == null) {
			buttonState.background.graphics.clear();
			buttonState.background.graphics.beginFill(0x333333, 1.0);
			buttonState.background.graphics.drawRect(0.0, 0.0, width, height);
			buttonState.background.graphics.endFill();

			buttonState.bitmap.bitmapData = null;
		} else {
			buttonState.background.graphics.clear();

			TextureHelper.apply_to_bitmap(buttonState.bitmap, texture);

			buttonState.bitmap.width = width;
			buttonState.bitmap.height = height;
		}

		state.lastTextureId = textureId;
		buttonState.lastPressed = button.pressed;
		buttonState.lastHovered = button.hovered;
		buttonState.lastDisabled = button.disabled;

		button.clear_dirty(DirtyFlag.Texture);
		button.clear_dirty(DirtyFlag.Visual);
		button.clear_dirty(DirtyFlag.Layout);
	}
}
