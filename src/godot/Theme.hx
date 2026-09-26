package godot;

class Theme extends Resource {
	public static var defaultTheme:Theme = create_default();

	public var defaultFont:Null<Font>;
	public var defaultFontSize:Int;

	var colors:Map<String, Color>;
	var constants:Map<String, Float>;
	var fonts:Map<String, Font>;

	public function new() {
		super();

		defaultFont = null;
		defaultFontSize = 16;

		colors = new Map<String, Color>();
		constants = new Map<String, Float>();
		fonts = new Map<String, Font>();
	}

	public static function create_default():Theme {
		var theme:Theme = new Theme();

		theme.defaultFontSize = 16;

		theme.set_color("font_color", Color.white());
		theme.set_color("font_color_disabled", new Color(0.55, 0.55, 0.55, 1.0));

		theme.set_color("button_normal", make_color(0x333333));
		theme.set_color("button_hover", make_color(0x444444));
		theme.set_color("button_pressed", make_color(0x222222));
		theme.set_color("button_disabled", make_color(0x2A2A2A));

		theme.set_color("panel", make_color(0x1F1F1F));

		theme.set_color("progress_background", make_color(0x222222));
		theme.set_color("progress_fill", make_color(0x33AA33));

		theme.set_constant("margin_left", 0.0);
		theme.set_constant("margin_top", 0.0);
		theme.set_constant("margin_right", 0.0);
		theme.set_constant("margin_bottom", 0.0);

		return theme;
	}

	public function set_color(name:String, color:Color):Void {
		colors.set(name, color);
	}

	public function get_color(name:String, fallback:Color):Color {
		var value:Null<Color> = colors.get(name);
		return value != null ? value : fallback;
	}

	public function set_constant(name:String, value:Float):Void {
		constants.set(name, value);
	}

	public function get_constant(name:String, fallback:Float):Float {
		var value:Null<Float> = constants.get(name);
		return value != null ? value : fallback;
	}

	public function set_font(name:String, font:Font):Void {
		fonts.set(name, font);
	}

	public function get_font(name:String):Null<Font> {
		return fonts.get(name);
	}

	static function make_color(rgb:Int):Color {
		var r:Float = ((rgb >> 16) & 0xFF) / 255.0;
		var g:Float = ((rgb >> 8) & 0xFF) / 255.0;
		var b:Float = (rgb & 0xFF) / 255.0;

		return new Color(r, g, b, 1.0);
	}
}
