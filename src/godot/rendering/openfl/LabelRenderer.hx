package godot.rendering.openfl;

import godot.Label;
import godot.DynamicFont;
import godot.Theme;
import godot.DirtyFlag;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.geom.Rectangle;

class LabelRenderState extends RenderObjectState {
	public var container:Sprite;
	public var textField:TextField;

	public var lastText:String;
	public var lastFontName:String;
	public var lastFontSize:Int;
	public var lastTextColor:Int;

	public var lastAlign:Int;
	public var lastVAlign:Int;

	public var lastAutowrap:Bool;
	public var lastClipText:Bool;

	public function new() {
		super();

		container = new Sprite();
		textField = new TextField();

		lastText = "";
		lastFontName = "";
		lastFontSize = -1;
		lastTextColor = -1;

		lastAlign = -1;
		lastVAlign = -1;

		lastAutowrap = false;
		lastClipText = false;

		textField.selectable = false;
		textField.mouseEnabled = false;
		textField.background = false;
		textField.border = false;
	}
}

class LabelRenderer {
	var renderer:Renderer;

	public function new(renderer:Renderer) {
		this.renderer = renderer;
	}

	public function create_state(label:Label):RenderObjectState {
		var state:LabelRenderState = new LabelRenderState();

		state.container.addChild(state.textField);
		state.displayObject = state.container;

		renderer.add_gui_object(state.container);

		update(label, state);

		return state;
	}

	public function update_if_dirty(label:Label, state:RenderObjectState):Void {
		var labelState:Null<LabelRenderState> = Std.instance(state, LabelRenderState);
		if (labelState == null) {
			return;
		}

		var dynamicFont:Null<DynamicFont> = get_dynamic_font(label);
		var fontName:String = get_font_name(label);
		var fontSize:Int = get_font_size(label, dynamicFont);
		var textColor:Int = label.textColor.to_argb32();

		var needsUpdate:Bool = labelState.lastText != label.text
			|| labelState.lastFontName != fontName
			|| labelState.lastFontSize != fontSize
			|| labelState.lastTextColor != textColor
			|| labelState.lastAlign != label.align
			|| labelState.lastVAlign != label.valign
			|| labelState.lastAutowrap != label.autowrap
			|| labelState.lastClipText != label.clipText
			|| labelState.lastWidth != label.rectSize.x
			|| labelState.lastHeight != label.rectSize.y
			|| label.is_dirty(DirtyFlag.Text)
			|| label.is_dirty(DirtyFlag.Visual)
			|| label.is_dirty(DirtyFlag.Layout);

		if (!needsUpdate) {
			return;
		}

		update(label, labelState);

		label.clear_dirty(DirtyFlag.Text);
		label.clear_dirty(DirtyFlag.Visual);
		label.clear_dirty(DirtyFlag.Layout);
	}

	function update(label:Label, state:LabelRenderState):Void {
		var dynamicFont:Null<DynamicFont> = get_dynamic_font(label);
		var fontName:String = get_font_name(label);
		var fontSize:Int = get_font_size(label, dynamicFont);
		var textColor:Int = label.textColor.to_argb32() & 0xFFFFFF;

		var format:TextFormat = new TextFormat(fontName, fontSize, textColor);

		if (dynamicFont != null) {
			format.letterSpacing = dynamicFont.spacingLeft + dynamicFont.spacingRight;
		}

		format.align = convert_align(label.align);

		state.textField.defaultTextFormat = format;
		state.textField.text = label.text;
		state.textField.setTextFormat(format);

		var width:Float = label.rectSize.x;
		var height:Float = label.rectSize.y;

		if (width > 0.0) {
			state.textField.autoSize = TextFieldAutoSize.NONE;
			state.textField.wordWrap = label.autowrap;
			state.textField.width = width;

			if (height > 0.0) {
				state.textField.height = height;
			}
		} else {
			state.textField.autoSize = TextFieldAutoSize.LEFT;
			state.textField.wordWrap = false;
		}

		apply_vertical_alignment(label, state);
		apply_clipping(label, state);

		state.lastText = label.text;
		state.lastFontName = fontName;
		state.lastFontSize = fontSize;
		state.lastTextColor = label.textColor.to_argb32();

		state.lastAlign = label.align;
		state.lastVAlign = label.valign;

		state.lastAutowrap = label.autowrap;
		state.lastClipText = label.clipText;

		state.lastWidth = label.rectSize.x;
		state.lastHeight = label.rectSize.y;
	}

	function apply_vertical_alignment(label:Label, state:LabelRenderState):Void {
		if (label.rectSize.y <= 0.0) {
			state.textField.y = 0.0;
			return;
		}

		var textHeight:Float = state.textField.textHeight;

		if (label.valign == Label.VALIGN_CENTER) {
			state.textField.y = (label.rectSize.y - textHeight) * 0.5;
		} else if (label.valign == Label.VALIGN_BOTTOM) {
			state.textField.y = label.rectSize.y - textHeight;
		} else {
			state.textField.y = 0.0;
		}

		if (state.textField.y < 0.0) {
			state.textField.y = 0.0;
		}
	}

	function apply_clipping(label:Label, state:LabelRenderState):Void {
		if (label.clipText && label.rectSize.x > 0.0) {
			var clipHeight:Float = label.rectSize.y > 0.0 ? label.rectSize.y : state.textField.height;

			state.textField.scrollRect = new Rectangle(0.0, 0.0, label.rectSize.x, clipHeight);
		} else {
			state.textField.scrollRect = null;
		}
	}

	function get_dynamic_font(label:Label):Null<DynamicFont> {
		var font:Null<godot.Font> = label.font;

		if (font == null) {
			var theme:Null<Theme> = label.get_effective_theme();
			if (theme != null) {
				font = theme.defaultFont;
			}
		}

		return Std.instance(font, DynamicFont);
	}

	function get_font_size(label:Label, dynamicFont:Null<DynamicFont>):Int {
		if (dynamicFont != null && dynamicFont.size > 0) {
			return dynamicFont.size;
		}

		if (label.fontSize > 0) {
			return label.fontSize;
		}

		var theme:Null<Theme> = label.get_effective_theme();
		if (theme != null && theme.defaultFontSize > 0) {
			return theme.defaultFontSize;
		}

		return 16;
	}

	function get_font_name(label:Label):String {
		var dynamicFont:Null<DynamicFont> = get_dynamic_font(label);

		if (dynamicFont != null) {
			var name:String = dynamicFont.get_effective_font_name();
			if (name.length > 0) {
				return name;
			}
		}

		return "Arial";
	}

	function convert_align(align:Int):TextFormatAlign {
		if (align == Label.ALIGN_CENTER) {
			return TextFormatAlign.CENTER;
		}

		if (align == Label.ALIGN_RIGHT) {
			return TextFormatAlign.RIGHT;
		}

		return TextFormatAlign.LEFT;
	}
}
