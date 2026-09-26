package godot.rendering.openfl;

import godot.Button;
import godot.Color;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class ButtonRenderState extends RenderObjectState {
	public var background:Sprite;
	public var textField:TextField;

	public var lastText:String;
	public var lastPressed:Bool;
	public var lastHovered:Bool;
	public var lastDisabled:Bool;

	public function new() {
		super();

		background = new Sprite();
		textField = new TextField();

		lastText = "";
		lastPressed = false;
		lastHovered = false;
		lastDisabled = false;

		textField.selectable = false;
		textField.mouseEnabled = false;
	}
}

class ButtonRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(button:Button):RenderObjectState {
		var state:ButtonRenderState = new ButtonRenderState();
		var container:Sprite = new Sprite();

		container.addChild(state.background);
		container.addChild(state.textField);

		state.displayObject = container;
		renderer.add_gui_object(container);

		return state;
	}

	public function update_if_dirty(button:Button, state:RenderObjectState):Void {
		var buttonState:Null<ButtonRenderState> = Std.instance(state, ButtonRenderState);
		if (buttonState == null) {
			return;
		}

		var needsUpdate:Bool = buttonState.lastText != button.text
			|| buttonState.lastWidth != state.lastWidth
			|| buttonState.lastHeight != state.lastHeight
			|| buttonState.lastPressed != button.pressed
			|| buttonState.lastHovered != button.hovered
			|| buttonState.lastDisabled != button.disabled;

		if (!needsUpdate) {
			return;
		}

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;

		if (Math.isNaN(width))
			width = 0.0;
		if (Math.isNaN(height))
			height = 0.0;

		var theme:Null<godot.Theme> = button.get_effective_theme();

		var color:godot.Color;

		if (theme != null) {
			if (button.disabled) {
				color = theme.get_color("button_disabled", new godot.Color(0.16, 0.16, 0.16, 1.0));
			} else if (button.pressed) {
				color = theme.get_color("button_pressed", new godot.Color(0.13, 0.13, 0.13, 1.0));
			} else if (button.hovered) {
				color = theme.get_color("button_hover", new godot.Color(0.27, 0.27, 0.27, 1.0));
			} else {
				color = theme.get_color("button_normal", new godot.Color(0.2, 0.2, 0.2, 1.0));
			}
		} else {
			if (button.disabled) {
				color = new godot.Color(0.16, 0.16, 0.16, 1.0);
			} else if (button.pressed) {
				color = new godot.Color(0.13, 0.13, 0.13, 1.0);
			} else if (button.hovered) {
				color = new godot.Color(0.27, 0.27, 0.27, 1.0);
			} else {
				color = new godot.Color(0.2, 0.2, 0.2, 1.0);
			}
		}

		buttonState.background.graphics.clear();
		buttonState.background.graphics.beginFill(color.to_argb32() & 0xFFFFFF, color.a);
		buttonState.background.graphics.drawRect(0.0, 0.0, width, height);
		buttonState.background.graphics.endFill();

		buttonState.textField.text = button.text;
		buttonState.textField.width = width;
		buttonState.textField.height = height;

		var textColor:Int = button.disabled ? 0x888888 : 0xFFFFFF;

		var format:openfl.text.TextFormat = new openfl.text.TextFormat("Arial", 16, textColor, button.disabled);

		format.align = openfl.text.TextFormatAlign.CENTER;

		buttonState.textField.defaultTextFormat = format;
		buttonState.textField.setTextFormat(format);

		buttonState.lastText = button.text;
		buttonState.lastPressed = button.pressed;
		buttonState.lastHovered = button.hovered;
		buttonState.lastDisabled = button.disabled;
	}
}
