package godot;

class RichTextLabel extends Control {
	public var text:String;
	public var bbcodeEnabled:Bool;
	public var fontSize:Int;
	public var textColor:Color;
	public var font:Null<Font>;

	public function new() {
		super();

		text = "";
		bbcodeEnabled = false;
		fontSize = 16;
		textColor = Color.white();
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

	public function set_bbcode(value:String):Void {
		bbcodeEnabled = true;
		set_text(value);
	}

	public function append_text(value:String):Void {
		set_text(text + value);
	}

	public function clear():Void {
		set_text("");
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

			case "bbcode_text":
				if (value.stringValue != null) {
					set_bbcode(value.stringValue);
					return true;
				}

			case "bbcode_enabled":
				if (value.boolValue != null) {
					bbcodeEnabled = value.boolValue;
					mark_dirty(DirtyFlag.Text);
					return true;
				}

			case "custom_fonts/normal_font":
				var resource:Null<Resource> = ResourceFactory.create_resource_from_value(value, doc);
				var loadedFont:Null<Font> = Std.instance(resource, Font);

				font = loadedFont;
				mark_dirty(DirtyFlag.Text);
				mark_dirty(DirtyFlag.Visual);

				return true;

			case "custom_colors/default_color":
				if (value.colorValue != null) {
					textColor = value.colorValue;
					mark_dirty(DirtyFlag.Text);
					mark_dirty(DirtyFlag.Visual);
					return true;
				}
		}

		return super.set_property(name, value, doc);
	}
}
