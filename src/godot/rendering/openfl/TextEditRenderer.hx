package godot.rendering.openfl;

import godot.TextEdit;
import godot.Engine;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class TextEditRenderState extends RenderObjectState {
	public var background:Sprite;
	public var textField:TextField;

	public var lastText:String;
	public var lastFocused:Bool;

	public function new() {
		super();

		background = new Sprite();
		textField = new TextField();

		lastText = "";
		lastFocused = false;

		textField.selectable = false;
		textField.mouseEnabled = false;
		textField.wordWrap = true;
	}
}

class TextEditRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(textEdit:TextEdit):RenderObjectState {
		var state:TextEditRenderState = new TextEditRenderState();
		var container:Sprite = new Sprite();

		container.addChild(state.background);
		container.addChild(state.textField);

		state.displayObject = container;
		renderer.add_gui_object(container);

		return state;
	}

	public function update_if_dirty(textEdit:TextEdit, state:RenderObjectState):Void {
		var textEditState:Null<TextEditRenderState> = Std.instance(state, TextEditRenderState);
		if (textEditState == null) {
			return;
		}

		var focused:Bool = Engine.mainSceneTree != null && Engine.mainSceneTree.guiState.focused == textEdit;

		var displayText:String = textEdit.get_display_text_with_caret(focused);

		var needsUpdate:Bool = textEditState.lastText != displayText
			|| textEditState.lastFocused != focused
			|| state.lastWidth != textEdit.rectSize.x
			|| state.lastHeight != textEdit.rectSize.y
			|| textEdit.is_dirty(DirtyFlag.Text)
			|| textEdit.is_dirty(DirtyFlag.Layout);

		if (!needsUpdate) {
			return;
		}

		var width:Float = state.lastWidth;
		var height:Float = state.lastHeight;

		if (Math.isNaN(width))
			width = 0.0;
		if (Math.isNaN(height))
			height = 0.0;

		var backgroundColor:Int = focused ? 0x333344 : 0x222222;

		textEditState.background.graphics.clear();
		textEditState.background.graphics.beginFill(backgroundColor, 1.0);
		textEditState.background.graphics.drawRect(0.0, 0.0, width, height);
		textEditState.background.graphics.endFill();

		textEditState.textField.text = displayText;
		textEditState.textField.width = width;
		textEditState.textField.height = height;

		var format:TextFormat = new TextFormat("Arial", 16, 0xFFFFFF);

		textEditState.textField.defaultTextFormat = format;
		textEditState.textField.setTextFormat(format);

		textEditState.lastText = displayText;
		textEditState.lastFocused = focused;

		textEdit.clear_dirty(DirtyFlag.Text);
		textEdit.clear_dirty(DirtyFlag.Layout);
	}
}
