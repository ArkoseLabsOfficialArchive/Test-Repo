package godot;

class Font extends Resource {
	public var fontName:String;
	public var defaultFontSize:Int;

	public function new() {
		super();

		fontName = "";
		defaultFontSize = 16;
	}

	public function get_font_name():String {
		return fontName;
	}
}
