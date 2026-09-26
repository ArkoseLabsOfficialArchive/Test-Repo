package godot;

class Label extends Control {
	public static var ALIGN_LEFT:Int = 0;
	public static var ALIGN_CENTER:Int = 1;
	public static var ALIGN_RIGHT:Int = 2;

	public static var VALIGN_TOP:Int = 0;
	public static var VALIGN_CENTER:Int = 1;
	public static var VALIGN_BOTTOM:Int = 2;

	public var text:String;
	public var fontSize:Int;
	public var textColor:Color;
	public var autowrap:Bool;
	public var clipText:Bool;

	public var align:Int;
	public var valign:Int;

	public var font:Null<Font>;

	public function new() {
		super();

		text = "";
		fontSize = 16;
		textColor = Color.white();

		autowrap = false;
		clipText = false;

		align = ALIGN_LEFT;
		valign = VALIGN_TOP;

		font = null;

		mouseFilter = MouseFilter.Ignore;
	}

	public function set_text(value:String):Void {
		if (text != value) {
			text = value;

			mark_dirty(DirtyFlag.Text);
			mark_dirty(DirtyFlag.Layout);
		}
	}

	public function set_font_color(value:Color):Void {
		textColor = value;
		mark_dirty(DirtyFlag.Visual);
		mark_dirty(DirtyFlag.Text);
	}

	public function set_font(value:Null<Font>):Void {
		font = value;
		mark_dirty(DirtyFlag.Text);
		mark_dirty(DirtyFlag.Visual);
	}

	override public function get_combined_minimum_size():Vector2 {
		var custom:Vector2 = customMinimumSize.copy();

		var lines:Array<String> = text.split("\n");
		var longest:Int = 0;

		for (line in lines) {
			if (line.length > longest) {
				longest = line.length;
			}
		}

		var estimatedWidth:Float = longest * fontSize * 0.6;
		var estimatedHeight:Float = lines.length * (fontSize + 4.0);

		if (custom.x > estimatedWidth)
			estimatedWidth = custom.x;
		if (custom.y > estimatedHeight)
			estimatedHeight = custom.y;

		return new Vector2(estimatedWidth, estimatedHeight);
	}

	override public function set_property(name:String, value:godot.tscn.TscnValue, doc:godot.tscn.TscnDocument):Bool {
		switch (name) {
			case "text":
				if (value.stringValue != null) {
					set_text(value.stringValue);
					return true;
				}

			case "autowrap":
				if (value.boolValue != null) {
					autowrap = value.boolValue;
					mark_dirty(DirtyFlag.Text);
					mark_dirty(DirtyFlag.Layout);
					return true;
				}

			case "clip_text":
				if (value.boolValue != null) {
					clipText = value.boolValue;
					mark_dirty(DirtyFlag.Text);
					return true;
				}

			case "align":
				if (value.intValue != null) {
					align = value.intValue;
					mark_dirty(DirtyFlag.Text);
					return true;
				}

			case "valign":
				if (value.intValue != null) {
					valign = value.intValue;
					mark_dirty(DirtyFlag.Text);
					return true;
				}

			case "custom_colors/font_color":
				if (value.colorValue != null) {
					set_font_color(value.colorValue);
					return true;
				}

			case "custom_fonts/font":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				var loadedFont:Null<Font> = Std.instance(resource, Font);

				set_font(loadedFont);
				return true;
		}

		return super.set_property(name, value, doc);
	}
}
