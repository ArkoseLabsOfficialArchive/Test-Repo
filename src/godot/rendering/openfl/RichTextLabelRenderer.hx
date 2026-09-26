package godot.rendering.openfl;

import godot.RichTextLabel;
import godot.BBCode;
import godot.DynamicFont;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;

class RichTextLabelRenderState extends RenderObjectState {
	public var container:Sprite;
	public var textField:TextField;

	public var lastText:String;
	public var lastHtml:String;
	public var lastFontSize:Int;
	public var lastFontName:String;

	public function new() {
		super();

		container = new Sprite();
		textField = new TextField();

		lastText = "";
		lastHtml = "";
		lastFontSize = -1;
		lastFontName = "";

		textField.selectable = false;
		textField.mouseEnabled = false;
		textField.background = false;
		textField.border = false;
		textField.wordWrap = true;
	}
}

class RichTextLabelRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(label:RichTextLabel):RenderObjectState {
		var state:RichTextLabelRenderState = new RichTextLabelRenderState();

		state.container.addChild(state.textField);
		state.displayObject = state.container;

		renderer.add_gui_object(state.container);

		update(label, state);

		return state;
	}

	public function update_if_dirty(label:RichTextLabel, state:RenderObjectState):Void {
		var richState:Null<RichTextLabelRenderState> = Std.instance(state, RichTextLabelRenderState);
		if (richState == null) {
			return;
		}

		var fontName:String = get_font_name(label);
		var html:String = label.bbcodeEnabled ? BBCode.to_html(label.text) : "";

		var needsUpdate:Bool = richState.lastText != label.text
			|| richState.lastHtml != html
			|| richState.lastFontSize != label.fontSize
			|| richState.lastFontName != fontName
			|| richState.lastWidth != label.rectSize.x
			|| richState.lastHeight != label.rectSize.y
			|| label.is_dirty(DirtyFlag.Text)
			|| label.is_dirty(DirtyFlag.Visual)
			|| label.is_dirty(DirtyFlag.Layout);

		if (!needsUpdate) {
			return;
		}

		update(label, richState);

		label.clear_dirty(DirtyFlag.Text);
		label.clear_dirty(DirtyFlag.Visual);
		label.clear_dirty(DirtyFlag.Layout);
	}

	function update(label:RichTextLabel, state:RichTextLabelRenderState):Void {
		var fontName:String = get_font_name(label);

		var format:TextFormat = new TextFormat(fontName, label.fontSize, label.textColor.to_argb32() & 0xFFFFFF);

		state.textField.defaultTextFormat = format;

		if (label.bbcodeEnabled) {
			state.textField.htmlText = BBCode.to_html(label.text);
		} else {
			state.textField.text = label.text;
		}

		state.textField.setTextFormat(format);

		if (label.rectSize.x > 0.0) {
			state.textField.autoSize = TextFieldAutoSize.NONE;
			state.textField.width = label.rectSize.x;

			if (label.rectSize.y > 0.0) {
				state.textField.height = label.rectSize.y;
			}
		} else {
			state.textField.autoSize = TextFieldAutoSize.LEFT;
		}

		state.lastText = label.text;
		state.lastHtml = label.bbcodeEnabled ? BBCode.to_html(label.text) : "";
		state.lastFontSize = label.fontSize;
		state.lastFontName = fontName;
		state.lastWidth = label.rectSize.x;
		state.lastHeight = label.rectSize.y;
	}

	function get_font_name(label:RichTextLabel):String {
		var font:Null<godot.Font> = label.font;

		if (font == null) {
			var theme:Null<godot.Theme> = label.get_effective_theme();
			if (theme != null) {
				font = theme.defaultFont;
			}
		}

		if (font != null && font.fontName.length > 0) {
			return font.fontName;
		}

		return "Arial";
	}
}
