package godot;

import godot.core.Log;

class DynamicFont extends Font {
	public var size:Int;
	public var outlineSize:Int;
	public var outlineColor:Color;

	public var useMipmaps:Bool;
	public var useFilter:Bool;

	public var spacingTop:Int;
	public var spacingBottom:Int;
	public var spacingLeft:Int;
	public var spacingRight:Int;

	public var fontPath:String;
	public var fontData:Null<DynamicFontData>; // Added for Godot 3 font_data property
	public var sourceFont:Null<DynamicFont>;
	public var openflFont:Null<openfl.text.Font>;

	public function new() {
		super();

		size = 16;
		outlineSize = 0;
		outlineColor = Color.black();

		useMipmaps = false;
		useFilter = true;

		spacingTop = 0;
		spacingBottom = 0;
		spacingLeft = 0;
		spacingRight = 0;

		fontPath = "";
		fontData = null;
		sourceFont = null;
		openflFont = null;

		defaultFontSize = size;
	}

	public function load_from_file(systemPath:String):Void {
		fontPath = systemPath;

		try {
			var bytes:openfl.utils.ByteArray = openfl.utils.ByteArray.fromBytes(sys.io.File.getBytes(systemPath));

			var loaded:Null<openfl.text.Font> = openfl.text.Font.fromBytes(bytes);

			if (loaded != null) {
				openflFont = loaded;
				fontName = loaded.fontName;
				defaultFontSize = size;
			} else {
				Log.warning("Font", "Runtime font load returned null font: " + systemPath);
			}
		} catch (e:Dynamic) {
			Log.warning("Font", "Failed to load runtime font: " + systemPath + " (" + Std.string(e) + ")");
		}
	}

	public function get_effective_font_name():String {
		if (fontName.length > 0)
			return fontName;
		if (sourceFont != null)
			return sourceFont.get_effective_font_name();
		return "";
	}

	public function get_effective_openfl_font():Null<openfl.text.Font> {
		if (openflFont != null)
			return openflFont;
		if (sourceFont != null)
			return sourceFont.get_effective_openfl_font();
		return null;
	}

	public function get_effective_size():Int {
		if (size > 0)
			return size;
		if (sourceFont != null && sourceFont.size > 0)
			return sourceFont.size;
		return defaultFontSize;
	}
}
